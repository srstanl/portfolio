import importlib.util
from pathlib import Path
import unittest

spec = importlib.util.spec_from_file_location('host', Path(__file__).parents[1] / 'verify-service-pods.py')
host = importlib.util.module_from_spec(spec)
spec.loader.exec_module(host)


class VerificationTests(unittest.TestCase):
    def pod(self):
        return dict(metadata=dict(uid='new'), spec=dict(containers=[dict(name='svc', image='registry/svc:tree', imagePullPolicy='Always')]),
                    status=dict(containerStatuses=[dict(name='svc', ready=True, imageID='registry/svc@sha256:abc')]))

    def valid(self, pod, previous={'old'}):
        return host.pods_verified(dict(items=[pod]), 'svc', 'registry/svc:tree', 'sha256:abc', previous)

    def test_new_ready_pod_with_expected_digest(self):
        self.assertTrue(self.valid(self.pod()))

    def test_reused_pod_rejected(self):
        self.assertFalse(self.valid(self.pod(), {'new'}))

    def test_wrong_digest_rejected(self):
        pod = self.pod()
        pod['status']['containerStatuses'][0]['imageID'] = 'registry/svc@sha256:wrong'
        self.assertFalse(self.valid(pod))

    def test_unready_or_missing_container_rejected(self):
        pod = self.pod()
        pod['status']['containerStatuses'][0]['ready'] = False
        self.assertFalse(self.valid(pod))
        pod['status']['containerStatuses'] = []
        self.assertFalse(self.valid(pod))

    def test_wrong_pull_policy_or_image_rejected(self):
        pod = self.pod()
        pod['spec']['containers'][0]['imagePullPolicy'] = 'Never'
        self.assertFalse(self.valid(pod))
        pod['spec']['containers'][0]['imagePullPolicy'] = 'Always'
        pod['spec']['containers'][0]['image'] = 'wrong'
        self.assertFalse(self.valid(pod))

    def test_empty_or_terminating_pods_rejected(self):
        self.assertFalse(host.pods_verified(dict(items=[]), 'svc', 'image', 'sha256:abc', set()))
        pod = self.pod()
        pod['metadata']['deletionTimestamp'] = 'now'
        self.assertFalse(self.valid(pod))


if __name__ == '__main__':
    unittest.main()
