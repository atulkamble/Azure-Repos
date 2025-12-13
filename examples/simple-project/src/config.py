"""
Configuration module for the simple project
"""

import os
from typing import Any, Dict


class Config:
    """Application configuration"""
    
    def __init__(self):
        self.version = "1.0.0"
        self.environment = os.getenv("ENVIRONMENT", "development")
        self.debug = os.getenv("DEBUG", "true").lower() == "true"
        self.message_prefix = os.getenv("MESSAGE_PREFIX", "[DEMO]")
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert configuration to dictionary"""
        return {
            "version": self.version,
            "environment": self.environment,
            "debug": self.debug,
            "message_prefix": self.message_prefix
        }
    
    def __str__(self) -> str:
        """String representation of configuration"""
        return f"Config(version={self.version}, env={self.environment}, debug={self.debug})"