//SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

/* Testing utilities */
import "./CommonTest.t.sol";
import { CrossDomainMessenger } from "../universal/CrossDomainMessenger.sol";



contract L1CrossDomainMessenger_GasBenchMark is Messenger_Initializer {
    // The amount of data typically sent during a bridge deposit.

    function test_L1MessengerSendMessage_benchmark() external {
        bytes memory data = hex"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff";
        L1Messenger.sendMessage(bob, data, uint32(100));
    }
}

contract L1StandardBridge_Deposit_GasBenchMark is Bridge_Initializer {
    function setUp() public virtual override {
        super.setUp();
        deal(address(L1Token), alice, 100000, true);
        vm.startPrank(alice, alice);
    }

    function test_depositETH_benchmark() external {
        L1Bridge.depositETH{ value: 500 }(50000, hex"");
    }

    function test_depositERC20_benchmark() external {
        L1Bridge.depositETH{ value: 500 }(50000, hex"");
    }
}

contract L1StandardBridge_Finalize_GasBenchMark is Bridge_Initializer {
    function setUp() public virtual override {
        super.setUp();
        deal(address(L1Token), address(L1Bridge), 100, true);
        vm.mockCall(
            address(L1Bridge.messenger()),
            abi.encodeWithSelector(CrossDomainMessenger.xDomainMessageSender.selector),
            abi.encode(address(L1Bridge.otherBridge()))
        );
        vm.deal(address(L1Bridge.messenger()), 100);
        vm.startPrank(address(L1Bridge.messenger()));
    }

    function test_finalizeETHWithdrawal_benchmark() external {
        // This is underestimating the cost because it pranks
        // the call coming from the messenger, which bypasses the portal
        // and oracle.
        L1Bridge.finalizeETHWithdrawal{ value: 100 }(
            alice,
            alice,
            100,
            hex""
        );
    }
}

contract OptimismPortal_GasBenchMark is Portal_Initializer {
    function setUp() public override {
        super.setUp();
    }

    function test_depositTransaction_benchmark() external {
        op.depositTransaction{ value: NON_ZERO_VALUE }(
            NON_ZERO_ADDRESS,
            ZERO_VALUE,
            NON_ZERO_GASLIMIT,
            false,
            NON_ZERO_DATA
        );
    }
}

contract L2OutputOracle_GasBenchMark is L2OutputOracle_Initializer {
    uint256 nextBlockNumber;
    function setUp() public override {
        super.setUp();
        nextBlockNumber = oracle.nextBlockNumber();
        warpToAppendTime(nextBlockNumber);
        vm.startPrank(sequencer);
    }

    function test_appendL2Output_benchmark() external {
        oracle.appendL2Output(nonZeroHash, nextBlockNumber, 0, 0);
    }
}
