class PremiumShopper: Shopper {
    var rewardsPoints: Int = 0

    override func makePurchase(amount: Double) {
        super.makePurchase(amount: amount)
        rewardsPoints += Int(amount)
    }
}
