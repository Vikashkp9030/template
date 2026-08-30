# Invoice templates

All six templates consume the same `InvoiceModel` and `InvoiceTotals`.

| Type | Class | Look |
| --- | --- | --- |
| `professional` | `ProfessionalInvoiceTemplate` | Corporate header, logo, item grid, signature |
| `modern` | `ModernInvoiceTemplate` | Large invoice number, customer card, teal total |
| `gst` | `GstInvoiceTemplate` | HSN, place of supply, reverse charge, CGST/SGST/IGST |
| `retail` | `RetailInvoiceTemplate` | SKU, salesperson, warehouse, outstanding |
| `premium` | `PremiumInvoiceTemplate` | Dark brand band, gold labels, summary card |
| `compact` | `CompactInvoiceTemplate` | Dense A4 table and tax summary |

Register new templates in `InvoiceTemplateRegistry`.
