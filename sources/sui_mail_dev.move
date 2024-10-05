/// Module: sui_mail_dev
module sui_mail_dev::sui_mail_dev {
    use sui::event;
    use std::string::{String};
    use std::vector;

    public struct Email has key, store {
        id: UID,
        sender: address,
        recipient: address,
        body: String,
        timestamp: u64,
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
        ctx: &mut TxContext
    ) {
        let email = Email {
            id: object::new(ctx),
            sender: tx_context::sender(ctx),
            recipient,
            body,
            is_read: false,
            attachments: vector::empty(),
            timestamp: tx_context::epoch(ctx),
        };

        event::emit(EmailSentEvent {
            email_id: object::uid_to_inner(&email.id),
            sender: tx_context::sender(ctx),
            recipient,
        });

        transfer::transfer(email, recipient);
    }

    public fun mark_as_read(email: &mut Email) {
        email.is_read = true
    }

    #[allow(unused_variable)]
    public fun delete_email(email: Email, _ctx: &mut TxContext) {
        let Email {
            id, 
            sender, 
            recipient, 
            body, 
            timestamp, 
            is_read, 
            attachments
        } = email;
        object::delete(id)
    }


    #[test]
    fun test_send_mail() {
        let ctx = &mut tx_context::dummy();
        send_email(tx_context::sender(ctx), b"Hello".to_string(), ctx);
    }
}
