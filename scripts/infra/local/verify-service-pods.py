#!/usr/bin/env python3
"""Reject stale or incorrect pods in the local registry delivery proof."""
import json
from pathlib import Path
import sys


def pods_verified(data, service, image, digest, previous, runtime_image=None):
    accepted = {digest}
    if runtime_image is not None:
        status = runtime_image.get('status', {})
        digests = {r.split('@')[-1] for r in status.get('repoDigests', [])}
        if digest not in digests or image not in status.get('repoTags', []):
            return False
        accepted = digests | {status.get('id', '')}
    pods = data.get('items', [])
    if not pods:
        return False
    for pod in pods:
        meta = pod['metadata']
        if meta['uid'] in previous or meta.get('deletionTimestamp'):
            return False
        containers = [c for c in pod['spec']['containers'] if c['name'] == service]
        statuses = [c for c in pod.get('status', {}).get('containerStatuses', []) if c['name'] == service]
        if len(containers) != 1 or len(statuses) != 1:
            return False
        container, status = containers[0], statuses[0]
        image_id = status.get('imageID', '').split('@')[-1].removeprefix('containerd://')
        if (container['image'] != image or container.get('imagePullPolicy') != 'Always'
                or not status.get('ready') or image_id not in accepted):
            return False
    return True

def main():
    service, image, digest, previous_path, runtime_path = sys.argv[1:]
    previous = {p['metadata']['uid'] for p in json.loads(Path(previous_path).read_text())['items']}
    current = json.load(sys.stdin)
    runtime_image = json.loads(Path(runtime_path).read_text())
    if not pods_verified(current, service, image, digest, previous, runtime_image):
        print('Expected new Ready pods with imagePullPolicy Always and the pushed registry digest.', file=sys.stderr)
        return 1
    for pod in current['items']:
        print('verified pod:', pod['metadata']['name'], 'uid:', pod['metadata']['uid'], 'digest:', digest)
    return 0


if __name__ == '__main__':
    sys.exit(main())
