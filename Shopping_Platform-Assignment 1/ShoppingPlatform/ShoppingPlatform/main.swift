import Foundation

func main() {
    let platform = ShoppingPlatform(platformName: "ShopSwift")

    while true {
        print("Select an option:")
        print("1. Create Premium Shopper account")
        print("2. Create Basic Shopper account")
        print("3. Make a purchase")
        print("4. Add rewards points (Premium Shopper)")
        print("5. Use discount coupon (Basic Shopper)")
        print("6. Check individual shopper's total spending")
        print("7. Check total spending across all shoppers")
        print("8. Refund an item")
        print("9. Remove a shopper")
        print("10. Exit")
        fflush(__stdoutp)

        guard let choice = readLine(), let intChoice = Int(choice) else {
                    print("Invalid choice!")
                    continue
                }
            switch intChoice {
            case 1:
                // Create Premium Shopper account
                print("Enter Shopper's name:")
                if let name = readLine() {
                    print("Enter Shopper's ID:")
                    if let shopperID = readLine() {
                        let premiumShopper = PremiumShopper(name: name, shopperID: shopperID)
                        platform.addShopper(shopper: premiumShopper)
                        print("Premium Shopper account created with ID: \(shopperID)")
                    } else {
                        print("Invalid shopper ID.")
                    }
                } else {
                    print("Invalid shopper name.")
                }
            case 2:
                // Create Basic Shopper account
                print("Enter Shopper's name:")
                if let name = readLine() {
                    print("Enter Shopper's ID:")
                    if let shopperID = readLine() {
                        let basicShopper = BasicShopper(name: name, shopperID: shopperID)
                        platform.addShopper(shopper: basicShopper)
                        print("Basic Shopper account created with ID: \(shopperID)")
                    } else {
                        print("Invalid shopper ID.")
                    }
                } else {
                    print("Invalid shopper name.")
                }
            case 3:
                // Make a purchase
                while true { // Transaction loop
                    print("Enter Shopper's ID:")
                    if let shopperID = readLine(), let shopper = platform.shoppers.first(where: { $0.shopperID == shopperID }) {
                        print("Enter purchase amount:")
                        if let purchaseAmountStr = readLine(), let purchaseAmount = Double(purchaseAmountStr) {
                            shopper.makePurchase(amount: purchaseAmount)
                            print("Purchase successful. New spending: \(shopper.checkSpending())")
                        } else {
                            print("Invalid purchase amount.")
                        }

                        print("Do you want to make another purchase? (yes/no)")
                        if let continueChoice = readLine(), continueChoice.lowercased() != "yes" {
                            break // Exit the transaction loop
                        }
                    } else {
                        print("Shopper not found.")
                    }
                }
            case 4:
                // Add rewards points (Premium Shopper)
                while true { // Transaction loop
                    print("Enter Shopper's ID:")
                    if let shopperID = readLine(), let premiumShopper = platform.shoppers.first(where: { $0.shopperID == shopperID }) as? PremiumShopper {
                        print("Enter rewards points to add:")
                        if let rewardsPointsStr = readLine(), let rewardsPoints = Int(rewardsPointsStr) {
                            premiumShopper.rewardsPoints += rewardsPoints
                            print("Rewards points added. Total rewards points: \(premiumShopper.rewardsPoints)")
                        } else {
                            print("Invalid rewards points value.")
                        }
                        
                        print("Do you want to add more rewards points? (yes/no)")
                        if let continueChoice = readLine(), continueChoice.lowercased() != "yes" {
                            break // Exit the transaction loop
                        }
                    } else {
                        print("Premium Shopper not found.")
                        break
                    }
                }
            case 5:
                // Use discount coupon (Basic Shopper)
                while true { // Transaction loop
                    print("Enter Shopper's ID:")
                    if let shopperID = readLine(), let basicShopper = platform.shoppers.first(where: { $0.shopperID == shopperID }) as? BasicShopper {
                        print("Enter discount coupon (as a decimal, e.g., 0.1 for 10%):")
                        if let discountStr = readLine(), let discount = Double(discountStr) {
                            basicShopper.discountCoupon = discount
                            print("Discount coupon applied.")
                        } else {
                            print("Invalid discount coupon value.")
                        }
                        
                        print("Do you want to apply another discount coupon? (yes/no)")
                        if let continueChoice = readLine(), continueChoice.lowercased() != "yes" {
                            break // Exit the transaction loop
                        }
                    } else {
                        print("Basic Shopper not found.")
                        break
                    }
                }
            case 6:
                print("Enter Shopper ID:")
                if let shopperID = readLine(), let shopper = platform.shoppers.first(where: { $0.shopperID == shopperID }) {
                    print("\(shopper.name) has spent a total of \(shopper.checkSpending() )")
                }
                
            case 7:
                // Check total spending across all shoppers
                let totalSpending = platform.totalPlatformSpending()
                print("Total spending across all shoppers: \(totalSpending)")
            case 8:
                // Refund an item
                while true { // Transaction loop
                    print("Enter Shopper's ID:")
                    if let shopperID = readLine(), let shopper = platform.shoppers.first(where: { $0.shopperID == shopperID }) {
                        print("Enter refund amount:")
                        if let refundAmountStr = readLine(), let refundAmount = Double(refundAmountStr) {
                            if shopper.totalSpending >= refundAmount {
                                shopper.refund(amount: refundAmount)
                                print("Refund successful. New spending: \(shopper.checkSpending())")
                            } else {
                                print("Refund amount exceeds total spending.")
                            }
                        } else {
                            print("Invalid refund amount.")
                        }
                        
                        print("Do you want to refund another item? (yes/no)")
                        if let continueChoice = readLine(), continueChoice.lowercased() != "yes" {
                            break // Exit the transaction loop
                        }
                    } else {
                        print("Shopper not found.")
                        break
                    }
                }
            case 9:
                            // Remove a shopper
                            print("Enter Shopper's ID to remove:")
                            if let shopperID = readLine() {
                                platform.removeShopper(by: shopperID)
                            } else {
                                print("Invalid shopper ID.")
                            }
            case 10:
                return // Exit the program
            default:
                print("Invalid choice!")
            }
        }
    }


main()
