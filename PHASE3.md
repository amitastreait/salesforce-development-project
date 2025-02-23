# Salesforce Development Project Phase 3

## Integration with Payment Gateway

## Setup Payment Object

## Payment and Refund Data Model Documentation

## Record Types

| Record Type Name | Description | Available For | Default |
|-----------------|-------------|---------------|----------|
| Payment | Used for recording payment transactions | All profiles | Yes |
| Refund | Used for recording full or partial refund transactions | System Administrator, Finance Users | No |

## Payment__c Object

| Field Label | Data Type | Required/Optional | Help Text | Description | Picklist Options | Available in Record Types |
|-------------|-----------|------------------|-----------|-------------|------------------|------------------------|
| Event Registration | Lookup(Event_Registration__c) | Required | Reference to event registration | Links the payment to registration | N/A | Payment, Refund |
| Parent Payment | Lookup(Payment__c) | Optional | Reference to original payment | Required for refunds - links to original payment | N/A | Refund |
| Record Type | Record Type | Required | Type of payment record | Determines if this is a payment or refund | Payment, Refund | Payment, Refund |
| Transaction Date | DateTime | Required | Date and time of transaction | When payment/refund was processed | N/A | Payment, Refund |
| Original Amount | Currency | Required | Original transaction amount | Full amount of original payment | N/A | Payment |
| Amount | Currency | Required | Transaction amount | Amount of payment or refund | N/A | Payment, Refund |
| Remaining Amount | Currency | Required | Amount available for refund | Original amount minus refunded amount | N/A | Payment |
| Status | Picklist | Required | Current status of transaction | Tracks processing status | For Payment: Pending, Processing, Completed, Failed, Partially Refunded, Fully Refunded; For Refund: Pending, Processing, Completed, Failed | Payment, Refund |
| Payment Method | Picklist | Required | Method used for transaction | Payment/refund method | Credit Card, PayPal, Bank Transfer, ACH, Wire Transfer | Payment, Refund |
| Transaction ID | Text(50) | Required | Gateway transaction reference | Unique identifier from payment gateway | N/A | Payment, Refund |
| Gateway Response | Long Text Area(32768) | Optional | Raw response from gateway | Complete gateway response for debugging | N/A | Payment, Refund |
| Gateway Error Message | Text(255) | Optional | Error details if transaction fails | Specific error message from gateway | N/A | Payment, Refund |
| Currency | Picklist | Required | Currency code for transaction | Currency used for transaction | USD, EUR, GBP, CAD, AUD | Payment, Refund |
| Processor Name | Picklist | Required | Payment processor used | Payment gateway/processor used | Stripe, PayPal, Square, Authorize.Net | Payment, Refund |
| Total Refunded Amount | Currency | Required | Sum of all refunds | Total amount refunded from this payment | N/A | Payment |
| Refund Reason | Picklist | Required for Refunds | Reason for refund | Why the refund was issued | Cancellation, Double Charge, Event Cancelled, Partial Cancellation, Customer Request, Other | Refund |
| Refund Type | Picklist | Required for Refunds | Type of refund | Whether full or partial refund | Full Refund, Partial Refund | Refund |
| Initiated By | Lookup(User) | Required for Refunds | User who initiated refund | Records who started the refund | N/A | Refund |
| Approved By | Lookup(User) | Required for Refunds | User who approved refund | Records who approved the refund | N/A | Refund |

## Payment_Line_Item__c Object

| Field Label | Data Type | Required/Optional | Help Text | Description | Picklist Options | Available in Record Types |
|-------------|-----------|------------------|-----------|-------------|------------------|------------------------|
| Payment | Lookup(Payment__c) | Required | Reference to parent record | Links to main transaction record | N/A | Payment, Refund |
| Original Line Item | Lookup(Payment_Line_Item__c) | Optional | Original payment line item | Links refund to original payment item | N/A | Refund |
| Item Type | Picklist | Required | Type of line item | Categorizes the line item | Registration Fee, Late Fee, Add-on Service, Tax | Payment, Refund |
| Original Amount | Currency | Required | Original item amount | Full amount of original line item | N/A | Payment |
| Amount | Currency | Required | Transaction amount | Amount for this line item | N/A | Payment, Refund |
| Remaining Amount | Currency | Required | Available for refund | Original amount minus refunded amount | N/A | Payment |
| Description | Text(255) | Required | Item description | Details of charge/refund | N/A | Payment, Refund |
| Tax Amount | Currency | Optional | Tax amount | Tax charged/refunded | N/A | Payment, Refund |
| Tax Rate | Percentage | Optional | Tax rate applied | Percentage of tax | N/A | Payment, Refund |
| Is Refundable | Checkbox | Required | Eligible for refund | Can this item be refunded | N/A | Payment |
| Refunded Amount | Currency | Required | Total refunded | Sum of refunds for this item | N/A | Payment |

# Payment and Refund System Validation & Automation Requirements

## Validation Rules

### Payment Object Validations

1. **Prevent Negative Payment Amount**
```apex
Rule Name: Payment_Amount_Cannot_Be_Negative
Error: Payment amount must be greater than zero
Condition: AND(
    RecordType.Name = 'Payment',
    Amount__c <= 0
)
```

2. **Refund Amount Validation**
```apex
Rule Name: Refund_Amount_Validation
Error: Refund amount cannot exceed the available balance
Condition: AND(
    RecordType.Name = 'Refund',
    Amount__c > Parent_Payment__r.Remaining_Amount__c
)
```

3. **Parent Payment Required for Refund**
```apex
Rule Name: Parent_Payment_Required_For_Refund
Error: Parent Payment is required for refund records
Condition: AND(
    RecordType.Name = 'Refund',
    ISBLANK(Parent_Payment__c)
)
```

4. **Prevent Double Refund**
```apex
Rule Name: Prevent_Double_Refund
Error: This payment has already been fully refunded
Condition: AND(
    RecordType.Name = 'Refund',
    Parent_Payment__r.Status__c = 'Fully Refunded'
)
```

5. **Valid Payment Method**
```apex
Rule Name: Valid_Payment_Method_Required
Error: Payment method is required and must match available gateway options
Condition: OR(
    ISBLANK(Payment_Method__c),
    AND(
        Payment_Method__c = 'Credit Card',
        Processor_Name__c = 'Bank Transfer'
    )
)
```

### Payment Line Item Validations

1. **Line Item Amount Validation**
```apex
Rule Name: Line_Item_Amount_Validation
Error: Line item amount cannot exceed the payment amount
Condition: Amount__c > Payment__r.Amount__c
```

2. **Refund Line Item Amount**
```apex
Rule Name: Refund_Line_Item_Amount
Error: Refund amount cannot exceed original line item's remaining amount
Condition: AND(
    Payment__r.RecordType.Name = 'Refund',
    Amount__c > Original_Line_Item__r.Remaining_Amount__c
)
```

3. **Tax Rate Validation**
```apex
Rule Name: Tax_Rate_Validation
Error: Tax rate must be between 0 and 100
Condition: OR(
    Tax_Rate__c < 0,
    Tax_Rate__c > 100
)
```

## Automation Requirements

### Payment Triggers

1. **Before Insert/Update Trigger**
```apex
trigger PaymentTrigger on Payment__c (before insert, before update) {
    // Validate payment amounts
    // Set default values
    // Calculate remaining amounts
    // Validate refund eligibility
}

Requirements:
- Set default status to 'Pending' for new payments
- Calculate remaining amount on payment records
- Validate refund amounts against parent payment
- Ensure payment currency matches event registration currency
- Set transaction date to current datetime if blank
```

2. **After Insert Trigger**
```apex
trigger PaymentTrigger on Payment__c (after insert) {
    // Update Event Registration status
    // Create payment line items if needed
    // Send confirmation emails
}

Requirements:
- Update Event Registration payment status
- Send payment confirmation email
- Create audit log entries
- Initiate payment gateway communication
```

3. **After Update Trigger**
```apex
trigger PaymentTrigger on Payment__c (after update) {
    // Handle status changes
    // Update related records
    // Send notifications
}

Requirements:
- Send notifications on status changes
- Update Event Registration when payment completed
- Handle refund processing
- Update parent payment for refunds
- Send refund confirmations
```

### Payment Line Item Triggers

1. **Before Insert/Update Trigger**
```apex
trigger PaymentLineItemTrigger on Payment_Line_Item__c (before insert, before update) {
    // Validate amounts
    // Calculate tax
    // Set default values
}

Requirements:
- Calculate tax amounts based on rate
- Validate line item amounts against payment total
- Set default values for new records
- Ensure currency matches parent payment
```

2. **After Insert/Update Trigger**
```apex
trigger PaymentLineItemTrigger on Payment_Line_Item__c (after insert, after update) {
    // Update payment totals
    // Handle refund line items
}

Requirements:
- Update payment total amounts
- Process refund line items
- Update original line item remaining amounts
- Create audit log entries
```

### Batch Jobs

1. **Payment Status Update Batch**
```apex
Requirements:
- Run every 15 minutes
- Update status of pending payments
- Check gateway for confirmation
- Handle failed payments
- Send notifications for status changes
```

2. **Refund Processing Batch**
```apex
Requirements:
- Run daily
- Process pending refunds
- Update payment statuses
- Send refund confirmations
- Create audit logs
```

### Scheduled Jobs

1. **Payment Reconciliation**
```apex
Requirements:
- Run nightly
- Reconcile payment totals
- Update remaining amounts
- Generate reconciliation reports
- Flag discrepancies for review
```

### Process Builder/Flow Requirements

1. **Payment Status Flow**
```
Requirements:
- Update Event Registration status based on payment status
- Send email notifications
- Create tasks for failed payments
- Update related records
```

2. **Refund Approval Process**
```
Requirements:
- Route refunds for approval based on amount
- Different approval paths for full vs partial refunds
- Automatic approval for small amounts
- Email notifications to approvers
- Update status after approval
```

## Error Handling

1. **Payment Processing Errors**
```apex
Requirements:
- Log all gateway errors
- Retry failed transactions up to 3 times
- Send notifications for repeated failures
- Create support cases for manual review
```

2. **Refund Processing Errors**
```apex
Requirements:
- Log refund processing errors
- Notify finance team of failures
- Create tasks for manual review
- Maintain audit trail of attempts
```
