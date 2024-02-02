class ShoppingPlatform {
    let platformName: String
    var shoppers: [Shopper] = []

    init(platformName: String) {
        self.platformName = platformName
    }

    func addShopper(shopper: Shopper) {
        shoppers.append(shopper)
    }

    func removeShopper(by shopperID: String) {
            if let index = shoppers.firstIndex(where: { $0.shopperID == shopperID }) {
                shoppers.remove(at: index)
                print("Shopper with ID \(shopperID) has been removed.")
            } else {
                print("Shopper with ID \(shopperID) not found.")
            }
        }

    func totalPlatformSpending() -> Double {
        return shoppers.reduce(0) { $0 + $1.checkSpending() }
    }
}
