"""
Tests for utils.py module
"""

import pytest
import sys
import os
from datetime import datetime

# Add src directory to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

from utils import format_message, get_timestamp, validate_config, safe_get


class TestUtils:
    """Test cases for utility functions"""
    
    def test_format_message_without_prefix(self):
        """Test format_message without prefix"""
        message = "Hello World"
        result = format_message(message)
        assert result == "Hello World"
    
    def test_format_message_with_prefix(self):
        """Test format_message with prefix"""
        message = "Hello World"
        prefix = "[TEST]"
        result = format_message(message, prefix)
        assert result == "[TEST] Hello World"
    
    def test_format_message_with_none_prefix(self):
        """Test format_message with None prefix"""
        message = "Hello World"
        result = format_message(message, None)
        assert result == "Hello World"
    
    def test_get_timestamp_format(self):
        """Test that get_timestamp returns ISO format"""
        timestamp = get_timestamp()
        
        # Should be able to parse as datetime
        try:
            datetime.fromisoformat(timestamp.replace('Z', '+00:00'))
            assert True
        except ValueError:
            assert False, f"Invalid timestamp format: {timestamp}"
    
    def test_get_timestamp_is_recent(self):
        """Test that timestamp is recent (within last minute)"""
        timestamp = get_timestamp()
        parsed_time = datetime.fromisoformat(timestamp.replace('Z', '+00:00').replace('+00:00', ''))
        now = datetime.now()
        
        diff = (now - parsed_time).total_seconds()
        assert abs(diff) < 60, "Timestamp should be within last minute"
    
    def test_validate_config_valid(self):
        """Test validate_config with valid config"""
        config = {
            "version": "1.0.0",
            "environment": "test",
            "debug": True
        }
        assert validate_config(config) == True
    
    def test_validate_config_missing_version(self):
        """Test validate_config with missing version"""
        config = {
            "environment": "test",
            "debug": True
        }
        assert validate_config(config) == False
    
    def test_validate_config_missing_environment(self):
        """Test validate_config with missing environment"""
        config = {
            "version": "1.0.0",
            "debug": True
        }
        assert validate_config(config) == False
    
    def test_validate_config_empty(self):
        """Test validate_config with empty config"""
        config = {}
        assert validate_config(config) == False
    
    def test_safe_get_existing_key(self):
        """Test safe_get with existing key"""
        data = {"key1": "value1", "key2": "value2"}
        result = safe_get(data, "key1")
        assert result == "value1"
    
    def test_safe_get_missing_key_with_default(self):
        """Test safe_get with missing key and default"""
        data = {"key1": "value1"}
        result = safe_get(data, "key2", "default_value")
        assert result == "default_value"
    
    def test_safe_get_missing_key_without_default(self):
        """Test safe_get with missing key and no default"""
        data = {"key1": "value1"}
        result = safe_get(data, "key2")
        assert result is None
    
    def test_safe_get_none_value(self):
        """Test safe_get with None value"""
        data = {"key1": None}
        result = safe_get(data, "key1", "default")
        assert result is None


# Performance tests
class TestUtilsPerformance:
    """Performance tests for utility functions"""
    
    def test_format_message_performance(self):
        """Test format_message performance with large strings"""
        large_message = "x" * 10000
        prefix = "[PERF]"
        
        import time
        start_time = time.time()
        
        for _ in range(1000):
            format_message(large_message, prefix)
        
        end_time = time.time()
        execution_time = end_time - start_time
        
        # Should complete 1000 iterations in under 1 second
        assert execution_time < 1.0, f"Performance test failed: {execution_time}s"


if __name__ == "__main__":
    pytest.main([__file__])