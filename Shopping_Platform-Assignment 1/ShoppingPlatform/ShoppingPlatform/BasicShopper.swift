class BasicShopper: Shopper {
    var discountCoupon: Double?

    override func makePurchase(amount: Double) {
        if let discount = discountCoupon {
            let discountedAmount = amount - (amount * discount)
            super.makePurchase(amount: discountedAmount)
        } else {
            super.makePurchase(amount: amount)
        }
    }
}
