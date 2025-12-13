"""
Tests for main.py module
"""

import pytest
import sys
import os

# Add src directory to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

from main import main
from config import Config


class TestMain:
    """Test cases for main module"""
    
    def test_main_returns_zero(self):
        """Test that main function returns 0 on success"""
        result = main()
        assert result == 0
    
    def test_config_initialization(self):
        """Test that config is properly initialized"""
        config = Config()
        assert config.version == "1.0.0"
        assert config.environment in ["development", "production", "testing"]
        assert isinstance(config.debug, bool)
    
    def test_config_to_dict(self):
        """Test config to_dict method"""
        config = Config()
        config_dict = config.to_dict()
        
        assert "version" in config_dict
        assert "environment" in config_dict
        assert "debug" in config_dict
        assert "message_prefix" in config_dict
    
    def test_config_string_representation(self):
        """Test config string representation"""
        config = Config()
        config_str = str(config)
        
        assert "Config(" in config_str
        assert "version=" in config_str
        assert "env=" in config_str
        assert "debug=" in config_str


if __name__ == "__main__":
    pytest.main([__file__])