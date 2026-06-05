import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["results", "spinner", "empty", "query"]
  static values = {
    url: String,
    defaultQuery: String,
    entityLabel: { type: String, default: "Вакансия" }
  }

  async search(event) {
    event.preventDefault()

    this.showSpinner()

    try {
      const query = this.searchQuery()
      const url = new URL(this.urlValue, window.location.origin)
      if (query) url.searchParams.set("text", query)

      const response = await fetch(url, {
        headers: { Accept: "application/json" }
      })

      const data = await response.json()

      if (!response.ok) {
        throw new Error(data.error || "Ошибка поиска на hh.ru")
      }

      this.renderResults(data.items, data.query)
    } catch (error) {
      this.renderError(error.message)
    } finally {
      this.hideSpinner()
    }
  }

  searchQuery() {
    if (this.hasQueryTarget) {
      return this.queryTarget.value.trim()
    }
    return this.defaultQueryValue
  }

  renderResults(items, query) {
    if (!items || items.length === 0) {
      this.resultsTarget.innerHTML = `<p class="text-muted p-3 mb-0">${this.emptyMessage()}</p>`
      return
    }

    const subtitle = query
      ? `<p class="text-muted small px-3 pt-3 mb-0">Запрос: ${this.escapeHtml(query)}</p>`
      : ""

    const rows = items.map((item) => `
      <tr>
        <td>
          <div>${this.escapeHtml(item.title)}</div>
          ${item.employer ? `<small class="text-muted">${this.escapeHtml(item.employer)}</small>` : ""}
        </td>
        <td>${this.scoreBadge(item)}</td>
      </tr>
    `).join("")

    this.resultsTarget.innerHTML = `
      ${subtitle}
      <div class="table-responsive">
        <table class="table table-hover mb-0">
          <thead>
            <tr>
              <th>${this.escapeHtml(this.entityLabelValue)}</th>
              <th>Оценка</th>
            </tr>
          </thead>
          <tbody>${rows}</tbody>
        </table>
      </div>
    `
  }

  renderError(message) {
    this.resultsTarget.innerHTML = `<div class="alert alert-danger m-3 mb-0">${this.escapeHtml(message)}</div>`
  }

  scoreBadge(item) {
    const cssClass = item.match_level === "high"
      ? "bg-success"
      : item.match_level === "medium"
        ? "bg-warning text-dark"
        : "bg-secondary"

    return `<span class="badge ${cssClass}">${item.score_percent}%</span>`
  }

  showSpinner() {
    if (this.hasSpinnerTarget) {
      this.spinnerTarget.classList.remove("d-none")
    }
  }

  hideSpinner() {
    if (this.hasSpinnerTarget) {
      this.spinnerTarget.classList.add("d-none")
    }
  }

  emptyMessage() {
    return this.hasEmptyTarget ? this.emptyTarget.textContent.trim() : "Ничего не найдено."
  }

  escapeHtml(value) {
    return String(value)
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
      .replaceAll("'", "&#39;")
  }
}
