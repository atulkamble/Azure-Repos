"""
Utility functions for the simple project
"""

from datetime import datetime
from typing import Optional


def format_message(message: str, prefix: Optional[str] = None) -> str:
    """
    Format a message with optional prefix
    
    Args:
        message: The message to format
        prefix: Optional prefix to add
    
    Returns:
        Formatted message string
    """
    if prefix:
        return f"{prefix} {message}"
    return message


def get_timestamp() -> str:
    """
    Get current timestamp in ISO format
    
    Returns:
        ISO formatted timestamp string
    """
    return datetime.now().isoformat()


def validate_config(config_dict: dict) -> bool:
    """
    Validate configuration dictionary
    
    Args:
        config_dict: Dictionary containing configuration
    
    Returns:
        True if valid, False otherwise
    """
    required_keys = ["version", "environment"]
    
    for key in required_keys:
        if key not in config_dict:
            return False
    
    return True


def safe_get(dictionary: dict, key: str, default: any = None) -> any:
    """
    Safely get value from dictionary with default
    
    Args:
        dictionary: Dictionary to get value from
        key: Key to lookup
        default: Default value if key not found
    
    Returns:
        Value from dictionary or default
    """
    return dictionary.get(key, default)