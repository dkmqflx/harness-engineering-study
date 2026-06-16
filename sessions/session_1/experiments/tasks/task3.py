def send_email(to, subject, body):
    message = {
        'to': to,
        'subject': subject,
        'body': body,
    }
    queue.push(message)
    return True
