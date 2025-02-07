"""Test for flask_bazel_sample"""

import unittest

from app import app


class TestAppRoutes(unittest.TestCase):
    """Testing all controllers"""

    def setUp(self):
        self.app = app.test_client()
        self.app.testing = True

    def test_welcome(self):
        """Testing welcome endpoint"""
        response = self.app.get("/")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(
            response.data.decode("utf-8"), "Welcome to Bazel built Flask!"
        )  # Check response body


if __name__ == "__main__":
    unittest.main()
