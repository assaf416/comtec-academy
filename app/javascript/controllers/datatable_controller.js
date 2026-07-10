import { Controller } from "@hotwired/stimulus"

// Enhances a server-rendered <table> with DataTables (search, sort, paging).
// RTL comes from the page dir="rtl"; the actions column (th.no-sort) is excluded.
export default class extends Controller {
  connect() {
    if (typeof window.DataTable === "undefined") return // library not loaded (e.g. offline/CI)

    this.table = new window.DataTable(this.element, {
      pageLength: 15,
      lengthChange: false,
      columnDefs: [{ orderable: false, searchable: false, targets: "no-sort" }],
      language: {
        search: "חיפוש:",
        info: "מציג _START_–_END_ מתוך _TOTAL_",
        infoEmpty: "אין רשומות",
        infoFiltered: "(מסונן מתוך _MAX_)",
        zeroRecords: "לא נמצאו תוצאות",
        emptyTable: "אין נתונים בטבלה",
        paginate: { first: "ראשון", last: "אחרון", next: "הבא", previous: "הקודם" }
      }
    })
  }

  disconnect() {
    if (this.table) { this.table.destroy(); this.table = null }
  }
}
