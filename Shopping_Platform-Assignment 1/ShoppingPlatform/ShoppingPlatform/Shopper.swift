class Shopper {
    let name: String
    let shopperID: String
    var totalSpending: Double = 0.0

    init(name: String, shopperID: String) {
        self.name = name
        self.shopperID = shopperID
    }

    func makePurchase(amount: Double) {
        totalSpending += amount
    }

    func refund(amount: Double) {
        totalSpending -= amount
    }

    func checkSpending() -> Double {
        return totalSpending
    }
}
