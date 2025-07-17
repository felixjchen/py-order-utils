# from eth_account import Account


class Signer:
    """
    Signs orders using a private key
    """

    def __init__(self, key: str):
        self._key = key
        # self.account = Account.from_key(key)

    async def sign(self, struct_hash) -> str:
        """
        Signs an EIP712 struct hash
        """
        print("python-order-utils sign is not supposed to be called.")

    def address(self) -> str:
        return self.account.address
