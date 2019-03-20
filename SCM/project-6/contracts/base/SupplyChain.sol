pragma solidity ^0.4.24;

import "../core/Ownable.sol";
import "../accessControl/ManufacturerRole.sol";
import "../accessControl/RetailerRole.sol";
import "../accessControl/ConsumerRole.sol";

// Define a contract 'Supplychain'
contract SupplyChain is  Ownable, ManufacturerRole, RetailerRole, ConsumerRole{

    // Define 'owner'
    address cowner;

    // Define a variable called 'upc' for Universal Product Code (UPC)
    uint  upc;

    // Define a variable called 'sku' for Stock Keeping Unit (SKU)
    uint  sku;

    // Define a public mapping 'items' that maps the UPC to an Item.
    mapping (uint => Item) items;

    // Define a public mapping 'itemsHistory' that maps the UPC to an array of TxHash, 
    // that track its journey through the supply chain -- to be sent from DApp.
    mapping (uint => string[]) itemsHistory;
    
    // Define enum 'State' with the following values:
    enum State 
    { 
      Procured, 
      Created,  
      ForSale,   
      Sold,      
      Shipped,   
      Received,  
      Displayed, 
      Purchased, 
      Packed,  
      CReceived   
    }

    State constant defaultState = State.Procured;

    // Define a struct 'Item' with the following fields:
    struct Item {
        uint    sku;  // Stock Keeping Unit (SKU)
        uint    upc; // Universal Product Code (UPC), generated by the Manufacturer, goes on the package, can be verified by the Consumer
        address ownerID;  // Metamask-Ethereum address of the current owner as the product moves through 10 stages
        address originManufacturerID; // Metamask-Ethereum address of the Manufacturer
        string  originManufacturerName; // Manufacturer Name
        string  originManufacturerInformation;  // Manufacturer Information
        string  originManufacturerCity; // Manufacturer city
        string  originManufacturerCountry;  // Manufacturer country
        uint    productID;  // Product ID potentially a combination of upc + sku
        string  productNotes; // Product Notes
        uint    productPrice; // Product Price
        State   itemState;  // Product State as represented in the enum above
        address retailerID; // Metamask-Ethereum address of the Retailer
        address consumerID; // Metamask-Ethereum address of the Consumer
    }

    // Define 8 events with the same 10 state values and accept 'upc' as input argument
    event Procured(uint upc);
    event Created(uint upc);
    event ForSale(uint upc);
    event Sold(uint upc);
    event Shipped(uint upc);
    event Received(uint upc);
    event Displayed(uint upc);
    event Purchased(uint upc);
    event Packed(uint upc);
    event CReceived(uint upc);

    // Define a modifer that checks to see if msg.sender == owner of the contract
    modifier onlyOwner() {
        require(msg.sender == cowner);
        _;
    }

    // Define a modifer that verifies the Caller
    modifier verifyCaller (address _address) {
        require(msg.sender == _address); 
        _;
    }

    // Define a modifier that checks if the paid amount is sufficient to cover the price
    modifier paidEnoughRetailer(uint _price) { 
        require(msg.value >= _price); 
        _;
    }

    // Define a modifier that checks if the paid amount is sufficient to cover the price
    modifier paidEnoughConsumer(uint _price) { 
        require(msg.value >= _price); 
        _;
    }
    
    // Define a modifier that checks the price and refunds the remaining balance
    // retailer is buying at 3x price
    modifier checkValueRetailer(uint _upc) {
        _;
        uint _price = items[_upc].productPrice;
        uint amountToReturn = msg.value - _price;
        items[_upc].retailerID.transfer(amountToReturn);
    }

    // Define a modifier that checks the price and refunds the remaining balance
    // consumer is buying at 6x price
    modifier checkValueConsumer(uint _upc) {
        _;
        uint _price = items[_upc].productPrice;
        uint amountToReturn = msg.value - _price;
        items[_upc].consumerID.transfer(amountToReturn);
    }

    // Define a modifier that checks if an item.state of a upc is Procured
    modifier procured(uint _upc) {
        require(items[_upc].itemState == State.Procured);
        _;
    }

    // Define a modifier that checks if an item.state of a upc is Created
    modifier created(uint _upc) {
        require(items[_upc].itemState == State.Created);
        _;
    }
 

    // Define a modifier that checks if an item.state of a upc is ForSale
    modifier forSale(uint _upc) {
        require(items[_upc].itemState == State.ForSale);
        _;
    }

    // Define a modifier that checks if an item.state of a upc is Sold
    modifier sold(uint _upc) {
        require(items[_upc].itemState == State.Sold);
        _;
    }
    
    // Define a modifier that checks if an item.state of a upc is Shipped
    modifier shipped(uint _upc) {
        require(items[_upc].itemState == State.Shipped);
        _;
    }

    // Define a modifier that checks if an item.state of a upc is Received
    modifier received(uint _upc) {
        require(items[_upc].itemState == State.Received);
        _;
    }

    // Define a modifier that checks if an item.state of a upc is Displayed
    modifier displayed(uint _upc) {
        require(items[_upc].itemState == State.Displayed);
        _;
    }

    // Define a modifier that checks if an item.state of a upc is Purchased
    modifier purchased(uint _upc) {
        require(items[_upc].itemState == State.Purchased);
        _;     
    }

    // Define a modifier that checks if an item.state of a upc is Packed
    modifier packed(uint _upc) {
        require(items[_upc].itemState == State.Packed);
        _;     
    }

    // Define a modifier that checks if an item.state of a upc is CReceived
    modifier creceived(uint _upc) {
        require(items[_upc].itemState == State.CReceived);
        _;     
    }

    // In the constructor set 'owner' to the address that instantiated the contract
    // and set 'sku' to 1
    // and set 'upc' to 1
    constructor() public payable {
        cowner = msg.sender;
        sku = 1;
        upc = 1;
    }

    // Define a function 'kill' if required
    function kill() public {
        if (msg.sender == cowner) {
            selfdestruct(cowner);
        }
    }

    // Define a function 'procureItem' that allows a manufacturer to mark an item 'Procured'
    function procureItem(uint _upc, address _originManufacturerID, string _originManufacturerName, string _originManufacturerInformation, string  _originManufacturerCity, string  _originManufacturerCountry, string  _productNotes) public 
    {
        // Add the new item as part of Harvest
        Item memory newItem;
        newItem.upc = _upc;
        newItem.sku = sku;
        newItem.productID = sku + _upc;
        newItem.productNotes = _productNotes;
        newItem.ownerID = _originManufacturerID;
        newItem.originManufacturerID = _originManufacturerID;
        newItem.originManufacturerName = _originManufacturerName;
        newItem.originManufacturerInformation = _originManufacturerInformation;
        newItem.originManufacturerCity = _originManufacturerCity;
        newItem.originManufacturerCountry = _originManufacturerCountry;
        newItem.itemState = defaultState;

        items[_upc] = newItem;
        
        // Increment sku
        sku = sku + 1;
        // Emit the appropriate event
        emit Procured(_upc);
    }



    // Define a function 'createItem' that allows a Manufacturer to mark an item 'Created'
    function createItem(uint _upc) public 
    // Call modifier to check if upc has passed previous supply chain stages
    procured(_upc)
    // Call modifier to verify caller of this function
    verifyCaller(items[_upc].ownerID)
    {
        // Update the appropriate fields
        items[_upc].itemState = State.Created;
        // Emit the appropriate event
        emit Created(_upc);
    }

    // Define a function 'sellItem' that allows a Manufacturer to mark an item 'ForSale'
    //putting item forSale by manufacturer, price is set by manufacturer
    function sellItem(uint _upc, uint _price) public 
    // Call modifier to check if upc has passed previous supply chain stage
    created(_upc)
    // Call modifier to verify caller of this function
    verifyCaller(items[_upc].ownerID)
    {
        // Update the appropriate fields
        items[_upc].productPrice = _price;
        items[_upc].itemState = State.ForSale;
        // Emit the appropriate event
        emit ForSale(_upc);
    }

//-------------------------------------------------------------------------------------------------------------------
    // Define a function 'buyItem' that allows the disributor to mark an item 'Sold'
    // Use the above defined modifiers to check if the item is available for sale, if the buyer has paid enough, 
    // and any excess ether sent is refunded back to the buyer
    function buyItem(uint _upc) public payable
      // Call modifier to check if upc has passed previous supply chain stage
      forSale(_upc)
      // Call modifer to check sif retailer has paid enough
      paidEnoughRetailer(items[_upc].productPrice)
      // Call modifer to send any excess ether back to buyer
      checkValueRetailer(_upc)
      {
      
      // Update the appropriate fields - ownerID, retailerId, itemState
        address retailer = msg.sender;
        items[_upc].ownerID = retailer;
        items[_upc].retailerID = retailer;
        items[_upc].itemState = State.Sold;

        // Transfer money to farmer
        items[_upc].originManufacturerID.transfer(items[_upc].productPrice);

        // Emit the appropriate event
        emit Sold(_upc);    
      
    }

    // Define a function 'shipItem' that allows the manufacturer to mark an item 'Shipped'
    // Use the above modifers to check if the item is sold
    function shipItem(uint _upc) public 
      // Call modifier to check if upc has passed previous supply chain stage
      sold(_upc)
      // Call modifier to verify caller of this function
      verifyCaller(items[_upc].originManufacturerID)
      {
        // Update the appropriate fields
        items[_upc].itemState = State.Shipped;
        // Emit the appropriate event
        emit Shipped(_upc);
    }

    // Define a function 'receiveItem' that allows the retailer to mark an item 'Received'
    // Use the above modifiers to check if the item is shipped
    function receiveItem(uint _upc) public 
      // Call modifier to check if upc has passed previous supply chain stage
      shipped(_upc)
      // Access Control List enforced by calling Smart Contract / DApp
      {
        // Update the appropriate fields - ownerID, retailerID, itemState
        items[_upc].itemState = State.Received;
        // Emit the appropriate event
        emit Received(_upc);
    }

    // Define a function 'sellItem' that allows a Manufacturer to mark an item 'ForSale'
    //putting item forSale by manufacturer, price is set by manufacturer
    function displayItem(uint _upc) public 
    // Call modifier to check if upc has passed previous supply chain stage
    received(_upc)
    // Call modifier to verify caller of this function
    verifyCaller(items[_upc].ownerID)
    {
        // Update the appropriate fields
        items[_upc].itemState = State.Displayed;   //ssame as for sale by retailer
        // Emit the appropriate event
        emit Displayed(_upc);
    }

    // Define a function 'purchaseItem' that allows the consumer to mark an item 'Purchased'
    // Use the above modifiers to check if the item is received
    function purchaseItem(uint _upc) public payable
      // Call modifier to check if upc has passed previous supply chain stage
      displayed(_upc)
      // Call modifer to check sif retailer has paid enough
      paidEnoughConsumer(items[_upc].productPrice)
      // Call modifer to send any excess ether back to buyer
      checkValueConsumer(_upc)
      {
      
      // Update the appropriate fields - ownerID, retailerId, itemState
        address consumer = msg.sender;
        items[_upc].ownerID = consumer;
        items[_upc].consumerID = consumer;
        items[_upc].itemState = State.Purchased;

        // Transfer money to farmer
        items[_upc].retailerID.transfer(items[_upc].productPrice);

        // Emit the appropriate event
        emit Purchased(_upc);    
    }


    // Define a function 'packItem' that allows the retailer to mark an item 'Packed'
    // Use the above modifers to check if the item is sold
    function packItem(uint _upc) public 
      // Call modifier to check if upc has passed previous supply chain stage
      purchased(_upc)
      // Call modifier to verify caller of this function
      verifyCaller(items[_upc].retailerID)
      {
        // Update the appropriate fields
        items[_upc].itemState = State.Packed;
        // Emit the appropriate event
        emit Packed(_upc);
    }    


    // Define a function 'creceiveItem' that allows the retailer to mark an item 'CReceived'
    // Use the above modifiers to check if the item is shipped
    function creceiveItem(uint _upc) public 
      // Call modifier to check if upc has passed previous supply chain stage
      packed(_upc)
      // Access Control List enforced by calling Smart Contract / DApp
      {
        //Just changing state is enough  
        items[_upc].itemState = State.CReceived;
        // Emit the appropriate event
        emit CReceived(_upc);
    }


    // Define a function 'fetchItemBufferOne' that fetches the data
    function fetchItemBufferOne(uint _upc) public view returns 
    (
    uint    itemSKU,
    uint    itemUPC,
    address ownerID,
    address originManufacturerID,
    string  originManufacturerName,
    string  originManufacturerInformation,
    string  originManufacturerCity,
    string  originManufacturerCountry
    ) 
    {
        // Assign values to the 8 parameters
        itemSKU = items[_upc].sku;
        itemUPC = items[_upc].upc;
        ownerID = items[_upc].ownerID;
        originManufacturerID = items[_upc].originManufacturerID;
        originManufacturerName = items[_upc].originManufacturerName;
        originManufacturerInformation = items[_upc].originManufacturerInformation;
        originManufacturerCity = items[_upc].originManufacturerCity;
        originManufacturerCountry = items[_upc].originManufacturerCountry;
        
        return 
        (
        itemSKU,
        itemUPC,
        ownerID,
        originManufacturerID,
        originManufacturerName,
        originManufacturerInformation,
        originManufacturerCity,
        originManufacturerCountry
        );
    }

    // Define a function 'fetchItemBufferTwo' that fetches the data
    function fetchItemBufferTwo(uint _upc) public view returns 
    (
    uint    itemSKU,
    uint    itemUPC,
    uint    productID,
    string  productNotes,
    uint    productPrice,
    State    itemState,
    address retailerID,
    address consumerID
    ) 
    {
      // Assign values to the 8 parameters
        itemSKU = items[_upc].sku;
        itemUPC = items[_upc].upc;
        productID = items[_upc].productID;
        productNotes = items[_upc].productNotes;
        productPrice = items[_upc].productPrice;
        itemState = items[_upc].itemState;
        retailerID = items[_upc].retailerID;
        consumerID = items[_upc].consumerID;
      
        return 
        (
        itemSKU,
        itemUPC,
        productID,
        productNotes,
        productPrice,
        itemState,
        retailerID,
        consumerID
        );
    }
}