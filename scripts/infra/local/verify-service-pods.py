#!/usr/bin/env python3
"""Reject stale or incorrect pods in the local registry delivery proof."""
import json
from pathlib import Path
import sys


def pods_verified(data, service, image, digest, previous):
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
                or not status.get('ready') or image_id != digest):
            return False
    return True


def main():
    service, image, digest, previous_path = sys.argv[1:]
    previous = {p['metadata']['uid'] for p in json.loads(Path(previous_path).read_text())['items']}
    current = json.load(sys.stdin)
    if not pods_verified(current, service, image, digest, previous):
        print('Expected new Ready pods with imagePullPolicy Always and the pushed registry digest.', file=sys.stderr)
        return 1
    for pod in current['items']:
        print('verified pod:', pod['metadata']['name'], 'uid:', pod['metadata']['uid'], 'digest:', digest)
    return 0


if __name__ == '__main__':
    sys.exit(main())
