from dataclasses import dataclass
from enum import Enum
from typing import Any, Optional


class ResponseCode(Enum):
    GET_SUCCESS = 200
    POST_SUCCESS = 201
    BAD_REQUEST = 400
    UNAUTHORIZED = 401
    NOT_FOUND = 404
    INTERNAL_ERROR = 500
    VALIDATION_ERROR = 422
    SERVICE_UNAVAILABLE = 503


class ResponseText(Enum):
    SUCCESS = "Operation completed successfully"
    BAD_REQUEST = "Invalid request parameters"
    UNAUTHORIZED = "Authentication required"
    NOT_FOUND = "Resource not found"
    INTERNAL_ERROR = "Internal server error"
    VALIDATION_ERROR = "Validation failed"
    SERVICE_UNAVAILABLE = "Service temporarily unavailable"


@dataclass
class ServerResponse:
    code: ResponseCode
    value: ResponseText
    data: Optional[float | dict] = None
