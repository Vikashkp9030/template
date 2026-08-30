# YAML data contract

Root must be a mapping. Unknown extra keys are ignored.

```yaml
template: professional   # optional: professional|modern|gst|retail|premium|compact
paperSize: a4            # optional: a4|a5|letter|58mm|80mm
taxRegime: gst_india     # gst_india|vat|none
interState: false        # true → IGST, false → CGST+SGST

company:
  name: "ABC Technologies Pvt Ltd"
  gstin: "36ABCDE1234F1Z5"
  phone: "+91 9876543210"
  email: "billing@abctech.com"
  website: "https://abctech.com"
  address:
    line1: "Madhapur"
    city: "Hyderabad"
    state: "Telangana"
    country: "India"
    pincode: "500081"

customer:
  name: "Rahul Sharma"
  phone: "+91 9123456789"
  email: "rahul@example.com"
  gstin: "36AAAAA1234A1Z5"
  billingAddress: { line1: "...", city: "...", state: "...", country: "India", pincode: "500034" }
  shippingAddress: { line1: "...", city: "...", state: "...", country: "India", pincode: "500076" }

invoice:
  number: "INV-2026-001"
  date: "2026-08-28"          # ISO or dd-MM-yyyy
  dueDate: "2026-09-05"
  currency: "INR"
  orderNumber: "SO-88421"
  salesperson: "Anita Reddy"
  warehouse: "HYD-WH-01"
  cashier: "Admin"
  placeOfSupply: "Telangana (36)"
  reverseCharge: false
  terms: "Payment due within 7 days."
  notes: "Thank you for your business."

bank:
  bankName: "HDFC Bank"
  accountName: "ABC Technologies Pvt Ltd"
  accountNumber: "50200011223344"
  ifsc: "HDFC0001234"
  upi: "abctech@hdfcbank"

payment:
  method: "UPI"
  status: "partial"          # paid|partial|unpaid
  paidAmount: 50000
  changeAmount: 0

items:
  - sku: "LAP-001"
    name: "Laptop"
    hsnSac: "8471"
    quantity: 1
    unit: "NOS"
    unitPrice: 65000
    discount: 2000
    taxRate: 18
```

## Validation

The parser rejects empty YAML, non-map roots, missing company/customer/invoice, invalid dates, and empty `items`. The calculator rejects negative tax, discount greater than line gross, and empty product lists.

## Example files

- `assets/sample_invoice.yaml`
- `assets/sample_pos.yaml`
- `assets/sample_erp.yaml`
