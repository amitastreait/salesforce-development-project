# Salesforce Practice Project: Next Steps

The project "Event Management" is used to manage the booking for a USA based client who wanted to manage all the fitness events that they are hosting across the various states and cities in USA as part of healthy life style. The customer wanted to have a community(UI) where any person who wanted to attend the event can see all the upcoming and past event. If the person wants to attend the event he/she can register for the event. 

The event information was being stored in Salesforce custom object (Event) and any registration were being stored in salesforce so that management can easily track the no of attendees for the event so that they can focus on the cities/states from where they are generating more revenue.

The project is using Sales Cloud and Community Cloud, Sales cloud to store all the information about event, event organizer, event speaker and event attendees including the Location of the events.

Whereas community cloud is used for the front-end where customers can view and register for the events.

## Pre-Requisites to Deploy

To deploy the code you must enable the following settings

- Digital Experience must be enabled in the target org
- After enabling the digital experience make sure the "Enable ExperienceBundle Metadata API" setting is enabled under the digital experience setting
    - Setup -> Feature Settings -> Digital Experiences --> Settings
 
![Enable ExperienceBundle Metadata API](https://github.com/user-attachments/assets/10c52ab1-7617-45f6-8908-937e914fff4c)


## Deploy the Codebase to the target org

- Clone the github repo using `git clone https://github.com/amitastreait/salesforce-development-project`
- Open the folder using VS Code
- Connect VS code to the target org
- run `sf project deploy start --manifest manifest/package.xml --target-org your_org_alias --wait 10 --ignore-conflicts` command to deploy the code to target org.
- Once the deployment is completed then assign `Event Management Object Permissions` permission set to your user & start using the application


# Salesforce Development Project Phase 3

Change the label of "Event Attendee" object to "Event Registration"

![Event Registration](https://github.com/user-attachments/assets/6b03159a-3c71-4074-ac22-ecfd1cf6adb2)

## Integration with Payment Gateway - Setup Payment Object

## Payment and Refund Data Model Documentation

Create a custom object with the following details

| Label | Plural Label | Object Name | Description |
|-------------|-----------|------------------|-----------|
| Razorpay Payment Transaction | Razorpay Payment Transactions | RazorpayPaymentTransaction | This object will store the attendees' payment information when they register for the event. |

![Razorpay Payment Transaction](https://github.com/user-attachments/assets/027fdab4-e3cc-41d9-bfa9-57d55bff733a)

## Record Types

| Record Type Name | Description | Available For | Default |
|-----------------|-------------|---------------|----------|
| Payment | Used for recording payment transactions | All profiles | Yes |
| Refund | Used for recording full or partial refund transactions | System Administrator, Finance Users | No |

## RazorpayPaymentTransaction__c Object

| Field Label | Data Type | Required/Optional | Help Text | Description | Picklist Options | Available in Record Types |
|-------------|-----------|------------------|-----------|-------------|------------------|------------------------|
| Event Registration | Lookup(Event_Registration__c) | Required | Reference to event registration | Links the payment to registration | N/A | Payment, Refund |
| Parent Payment | Lookup(RazorpayPaymentTransaction__c) | Optional | Reference to original payment | Required for refunds - links to original payment | N/A | Refund |
| Record Type | Record Type | Required | Type of payment record | Determines if this is a payment or refund | Payment, Refund | Payment, Refund |
| Transaction Date | DateTime | Required | Date and time of transaction | When payment/refund was processed | N/A | Payment, Refund |
| Original Amount | Currency | Required | Original transaction amount | Full amount of original payment | N/A | Payment |
| Amount | Currency | Required | Transaction amount | Amount of payment or refund | N/A | Payment, Refund |
| Remaining Amount | Formula | Optional | Amount available for refund | Original amount minus refunded amount | N/A | Payment |
| Status | Picklist | Required | Current status of transaction | Tracks processing status | For Payment: Pending, Processing, Completed, Failed, Partially Refunded, Fully Refunded; For Refund: Pending, Processing, Completed, Failed | Payment, Refund |
| Payment Method | Picklist | Required | Method used for transaction | Payment/refund method | Credit Card, PayPal, Bank Transfer, ACH, Wire Transfer | Payment, Refund |
| Transaction ID | Text(150) | Required | Gateway transaction reference | Unique identifier from payment gateway | N/A | Payment, Refund |
| Gateway Response | Long Text Area(32768) | Optional | Raw response from gateway | Complete gateway response for debugging | N/A | Payment, Refund |
| Gateway Error Message | Text(255) | Optional | Error details if transaction fails | Specific error message from gateway | N/A | Payment, Refund |
| Currency | Picklist | Required | Currency code for transaction | Currency used for transaction | USD, EUR, GBP, CAD, AUD, INR | Payment, Refund |
| Processor Name | Picklist | Required | Payment processor used | Payment gateway/processor used | Stripe, PayPal, RazorPay, Square, Authorize.Net | Payment, Refund |
| Total Refunded Amount | Currency | Required | Sum of all refunds | Total amount refunded from this payment | N/A | Payment |
| Refund Reason | Picklist | Required for Refunds | Reason for refund | Why the refund was issued | Cancellation, Double Charge, Event Cancelled, Partial Cancellation, Customer Request, Other | Refund |
| Refund Type | Picklist | Required for Refunds | Type of refund | Whether full or partial refund | Full Refund, Partial Refund | Refund |
| Initiated By | Lookup(User) | Required for Refunds | User who initiated refund | Records who started the refund | N/A | Refund |
| Approved By | Lookup(User) | Required for Refunds | User who approved refund | Records who approved the refund | N/A | Refund |

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

6. **Event Registration Must be required**
```apex
Rule Name: Event_Registration_Required
Error: Event Registration is required to create the Payment Record
Condition: AND(
    ISBLANK(Event_Registration__c)
)
```

7. **Original Amount must be required**
```apex
Rule Name: Original_Amount_Required
Error: Original Amount is required to create the Payment Record
Condition: AND(
    ISBLANK(Original_Amount__c)
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

### Flow Requirements

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

## Read All About It

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)