#!/usr/bin/env python3
"""
Simple Python application demonstrating Git workflow
"""

from config import Config
from utils import format_message, get_timestamp


def main():
    """Main application entry point"""
    config = Config()
    
    print("=== Simple Project Demo ===")
    print(f"Version: {config.version}")
    print(f"Environment: {config.environment}")
    print(f"Started at: {get_timestamp()}")
    
    # Demo functionality
    message = "Hello from Azure DevOps Git Demo!"
    formatted_message = format_message(message, config.message_prefix)
    
    print(f"\n{formatted_message}")
    
    if config.debug:
        print(f"\nDebug info:")
        print(f"- Config loaded: ✓")
        print(f"- Utils imported: ✓")
        print(f"- Application running: ✓")
    
    return 0


if __name__ == "__main__":
    exit(main())