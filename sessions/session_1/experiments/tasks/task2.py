def process_orders(orders):
    result = []
    for o in orders:
        if o['status'] == 'pending':
            if o['amount'] > 100:
                result.append({'id': o['id'], 'priority': 'high', 'amount': o['amount']})
            else:
                result.append({'id': o['id'], 'priority': 'normal', 'amount': o['amount']})
    return result
