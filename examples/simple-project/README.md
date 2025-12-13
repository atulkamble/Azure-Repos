# Simple Project Example

This is a basic project structure demonstrating Git and Azure DevOps integration.

## Project Structure

```
simple-project/
├── src/
│   ├── main.py          # Main application
│   ├── config.py        # Configuration
│   └── utils.py         # Utility functions
├── tests/
│   ├── test_main.py     # Main tests
│   └── test_utils.py    # Utility tests
├── requirements.txt     # Python dependencies
├── .gitignore          # Git ignore rules
├── README.md           # This file
└── azure-pipelines.yml # CI/CD configuration
```

## Getting Started

1. Clone this repository
2. Install dependencies: `pip install -r requirements.txt`
3. Run the application: `python src/main.py`
4. Run tests: `python -m pytest tests/`

## Features

- Simple Python application
- Unit testing with pytest
- Azure DevOps CI/CD pipeline
- Git best practices

## Development Workflow

1. Create feature branch: `git checkout -b feature/new-feature`
2. Make changes and commit: `git commit -m "feat: add new feature"`
3. Push branch: `git push -u origin feature/new-feature`
4. Create pull request in Azure DevOps
5. After review and approval, merge to main