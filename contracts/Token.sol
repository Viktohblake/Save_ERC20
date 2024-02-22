// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract VToken {
    string private TokenName;

    string private TokenSymbol;

    uint8 private TokenDecimals;

    uint256 private TokenSupply;

    address public owner;

    mapping(address => uint256) balance;

    mapping(address => mapping(address => uint256)) approval;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    constructor(
        string memory _tokenName,
        string memory _tokenSymbol,
        uint8 _tokenDecimals,
        uint256 _tokenSupply
    ) {
        owner = msg.sender;

        TokenName = _tokenName;

        TokenSymbol = _tokenSymbol;

        TokenDecimals = _tokenDecimals;

        TokenSupply = _tokenSupply;

        balance[owner] = TokenSupply;
    }

    function name() public view returns (string memory) {
        return TokenName;
    }

    function symbol() public view returns (string memory) {
        return TokenSymbol;
    }

    function decimals() public view returns (uint8) {
        return TokenDecimals;
    }

    function totalSupply() public view returns (uint256) {
        return TokenSupply;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balance[_owner];
    }

    function transfer(
        address payable _to,
        uint256 _value
    ) public returns (bool) {
        require(_to != address(0x0), "Wrong EOA");

        require(_value <= balance[msg.sender], "You Don't have enough Token");
        balance[msg.sender] = balance[msg.sender] - _value;

        balance[_to] = balance[_to] + _value;
        //(success, _to.call{value:_value}(""));
        //_to.transfer(_value);
        // Event
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool) {
        require(_to != address(0x0), "Wrong EOA");
        require(_value <= approval[_from][msg.sender]);
        uint256 _burnAmount = _value / 10;
        approval[_from][msg.sender] -= _value;
        balance[_from] -= _value;

        balance[_to] += _value;
        burn(_from, _burnAmount);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        approval[msg.sender][_spender] = _value;
        return true;
    }

    function allowance(
        address _owner,
        address _spender
    ) public view returns (uint256 approved) {
        return approval[_owner][_spender];
    }

    function burn(address _from, uint256 _value) internal {
        require(balance[_from] >= _value, "Insufficient balance to burn");
        balance[_from] = balance[_from] - _value;
        TokenSupply = TokenSupply - _value;
        emit Transfer(_from, address(0), _value);
    }
}