# Flask Bazel Template

This repository provides a template for building and deploying Flask applications with Bazel. It includes pre-configured Bazel rules for Python dependencies,  image creation, linting, formatting, and automated testing. The template is designed for scalability and ease of use, making it a great starting point for Flask-based projects.

## Prerequisites
- Familiarity with Git and code review processes, if you are not familiar go to [go/review](http://go/review)
- Ensure the following tools are installed on your system:
  - Python 3.x
  - Bazel (for building and pushing images)

## Getting Started
Clone the repository to your local environment:
```bash
git clone "http://review.circlecat.org/flask-bazel-template"
```

## Workflow

### 1. Run the Application
To run the Flask application locally:
```bash
bazel run //:flask_bazel_sample
```

### 2. Test the Application
To run the unit tests for the Flask application:
```bash
bazel test //:app_test
```

### 3. Build and Push OCI Image
To build and push the OCI image, follow these steps:

1. **Clean Bazel Cache (if needed)**:
   ```bash
   bazel clean
   ```

2.**Build the OCI Image**:
   ```bash
   bazel build //:flask_image
   ```

3. **Push the Image**:
   -Choice 1: Push to (non-existent) Default Repository:
   ```bash
   bazel run //:flask_image_push_dynamic
   ```

   -Choice 2: Push to a Specified Repository:
   ```bash
   bazel run //:flask_image_push_dynamic --action_env=REPO=xxxx --action_env=TAG=xxxx
   ```

### 4. Format and Lint the Code (before submitting CL)
Before submitting your code (pushing a CL), you are recommended to make sure that the code meets the required formatting and linting standards to maintain code quality.

- **Run Lint Checks**:
  ```bash
  bash lint.sh all_files
  ```

- **Format the Code**:
  ```bash
  bazel run //tools/format:format
  ```

### 5. Submit Code
After ensuring the code is formatted and linted, follow these steps to submit your changes for review:

1. Commit your changes:
   ```bash
   git commit -m "<Your commit message>"
   ```

2. Submit the code for review:
   ```bash
   git review
   ```

3. If you need to amend your changes, use:
   ```bash
   git commit --amend
   ```

## File Structure Overview
- **`BUILD`**: Contains Bazel build rules for the Flask app, tests, and the OCI image.
- **`MODULE.bazel`**: Defines external dependencies and Bazel modules.
- **`app.py`**: The main Flask application file.
- **`app_test.py`**: Unit tests for the Flask application.
- **`py_layer.bzl`**: Custom Bazel rules for Python OCI image layers.
- **`lint.sh`**: Script for running lint checks.
- **`.gitreview`**: Configuration for Gerrit code review.
- **`tools/`**: Contains Bazel rules for linting and formatting.

## Flask Application
The Flask application (`app.py`) includes a simple endpoint:
```python
@app.route("/")
def sample():
    return "Welcome to Bazel built Flask!"
```

## License
This project is licensed under the MIT License. See the [LICENSE] file for details.
