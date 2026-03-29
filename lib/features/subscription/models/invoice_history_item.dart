class InvoiceHistoryItem {
  const InvoiceHistoryItem({
    required this.id,
    this.number,
    required this.created,
    required this.amountPaid,
    required this.amountDue,
    required this.currency,
    required this.status,
    this.invoicePdf,
    this.hostedInvoiceUrl,
  });

  final String id;
  final String? number;
  final int created;
  final int amountPaid;
  final int amountDue;
  final String currency;
  final String status;
  final String? invoicePdf;
  final String? hostedInvoiceUrl;

  factory InvoiceHistoryItem.fromJson(Map<String, dynamic> json) {
    return InvoiceHistoryItem(
      id: json['id'] as String,
      number: json['number'] as String?,
      created: (json['created'] as num?)?.toInt() ?? 0,
      amountPaid: (json['amount_paid'] as num?)?.toInt() ?? 0,
      amountDue: (json['amount_due'] as num?)?.toInt() ?? 0,
      currency: (json['currency'] as String?) ?? 'usd',
      status: (json['status'] as String?) ?? 'unknown',
      invoicePdf: json['invoice_pdf'] as String?,
      hostedInvoiceUrl: json['hosted_invoice_url'] as String?,
    );
  }

  int get displayAmountCents => amountPaid > 0 ? amountPaid : amountDue;
}
