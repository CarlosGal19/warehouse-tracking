module warehouse_tracking::warehouse_tracking{

    use std::string::{String};
    use sui::vec_map::{VecMap, Self};

    // KEY: Unique blockchain identifier
    // STORE: Persist
    // DROP: Replace
    // COPY

    #[error]
    const INVALID_ID: vector<u8> = b"Product ID already exists";
    #[error]
    const NOT_ENOUGH_STOCK: vector<u8> = b"Not enough stock available";
    #[error]
    const NO_PRODUCT: vector<u8> = b"Product does not exist";

    public struct Warehouse has key {
        id:UID,
        name:String,
        products:VecMap<u16, Product>,
    }

    public struct Product has store, drop {
        id:u16,
        name:String,
        description:String,
        stock:u8,
        price:u16,
    }

    public fun createWarehouse(name: String, ctx: &mut TxContext) {
        let warehouse =  Warehouse {
            id: object::new(ctx),       // This will be the param for interacting with object
            name,
            // products: vec_map::empty()
            products: vec_map::empty()
        };

        transfer::transfer(warehouse, tx_context::sender(ctx))
    }

    public fun addProductToWarehouse(warehouse: &mut Warehouse, id: u16, name: String, description: String, stock: u8, price: u16) {

        assert!(!warehouse.products.contains(&id), INVALID_ID);

        let product = Product {
            id,
            name,
            description,
            stock,
            price
        };

        warehouse.products.insert(id, product);
    }

    public fun sellProduct(warehouse: &mut Warehouse, id: u16, quantity: u8) {
        let product = warehouse.products.get_mut(&id);
        assert!(product.stock > quantity, NOT_ENOUGH_STOCK);
        product.stock = product.stock - quantity;
    }

    public fun supplyProduct(warehouse: &mut Warehouse, id: u16, quantity: u8) {
        let product = warehouse.products.get_mut(&id);
        product.stock = product.stock + quantity;
    }

    public fun getProductInfo(warehouse: &mut Warehouse, product_id: u16): (String) {
        assert!(!warehouse.products.contains(&product_id), NO_PRODUCT);
        warehouse.products.get(&product_id).description
    }

    public fun deleteProduct(warehouse: &mut Warehouse, id: u16): (u16, Product) {
        assert!(!warehouse.products.contains(&id), NO_PRODUCT);
        warehouse.products.remove(&id)
    }
}
