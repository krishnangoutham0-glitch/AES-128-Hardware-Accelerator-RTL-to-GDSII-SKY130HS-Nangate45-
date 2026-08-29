from ..abstractions import UserPeripheral


class AES(UserPeripheral):
    """
    AES-128 hardware accelerator.
    """

    _name = "aes"

    def __init__(self, address: int = None, length: int = None):
        """
        Initialize the AES peripheral.

        :param int address: The virtual address of the AES peripheral
                            within the peripheral domain.
        :param int length: The address space reserved for the AES peripheral.
        """
        super().__init__(address, length)
