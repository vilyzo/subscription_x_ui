import base64


class Base64Encoder:
    def __init__(self):
        pass

    def encode(self, input_string: str) -> str:
        byte_string = input_string.encode("utf-8")
        base64_bytes = base64.b64encode(byte_string)
        return base64_bytes.decode("utf-8")

    def decode(self, input_string: str) -> str:
        base64_bytes = input_string.encode("utf-8")
        decoded_bytes = base64.b64decode(base64_bytes)
        return decoded_bytes.decode("utf-8")