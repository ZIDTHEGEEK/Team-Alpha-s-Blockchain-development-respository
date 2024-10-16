/// Module: sui_mail_dev
module sui_mail_dev::sui_mail_dev {
    use sui::event;
    use std::string::{String};

    public struct Inbox has key, store {
        id: UID,
        sender: address,
        recipient: address,
        body: String,
        aesKey: String,
        iv: String,
        timestamp: String,
        starred: bool,
        is_read: bool,
        attachments: vector<ID>,
    }

    public struct OutBox has key, store {
        id: UID,
        sender: address,
        recipient: address,
        body: String,
        aesKey: String,
        iv: String,
        timestamp: String,
        is_read: bool,
        attachments: vector<ID>,
    }
    
    public struct EmailSentEvent has copy, drop {
        email_id: ID,
        sender: address,
        recipient: address
    }

    public fun send_email(
        recipient: address, 
        body: String,
        aesKey: String,
        iv: String,
        timestamp: String,
        ctx: &mut TxContext
    ) {
        let inbox_mail = Inbox {
            id: object::new(ctx),
            sender: tx_context::sender(ctx),
            recipient,
            body,
            aesKey,
            iv,
            is_read: false,
            starred: false,
            attachments: vector::empty(),
            timestamp: timestamp,
        };

        let sentbox_mail = OutBox {
            id: object::new(ctx),
            sender: tx_context::sender(ctx),
            recipient,
            body,
            aesKey,
            iv,
            is_read: false,
            attachments: vector::empty(),
            timestamp: timestamp,
        };

        event::emit(EmailSentEvent {
            email_id: object::uid_to_inner(&inbox_mail.id),
            sender: tx_context::sender(ctx),
            recipient,
        });

        transfer::transfer(inbox_mail, recipient);
        transfer::transfer(sentbox_mail, tx_context::sender(ctx));
    }

    public fun mark_inbox_as_read(email: &mut Inbox) {
        email.is_read = true
    }

    #[allow(unused_variable)]
    public fun delete_inbox_mail(email: Inbox, _ctx: &mut TxContext) {
        let Inbox {
            id, 
            sender, 
            recipient, 
            body, 
            aesKey,
            iv,
            timestamp, 
            is_read, 
            starred,
            attachments
        } = email;
        object::delete(id)
    }

    #[test]
    fun test_send_mail() {
        let ctx = &mut tx_context::dummy();
        send_email(tx_context::sender(ctx), b"Hello".to_string(),  b"Nice one".to_string(), b"secret key".to_string(), b"Time stamp".to_string(), ctx);
    }
}
