def calculate_discount(price, user_type):
    if user_type == 'premium':
        discount = 0.2
    elif user_type == 'member':
        discount = 0.1
    else:
        discount = 0

    final_price = price * (1 - discount)
    return final_price
