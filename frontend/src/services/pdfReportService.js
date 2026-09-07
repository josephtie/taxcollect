import jsPDF from 'jspdf'
import autoTable from 'jspdf-autotable'

export function generateProductivityReport({ agents, stats, dateRange, recensementStats }) {
  const doc = new jsPDF({ orientation: 'portrait', unit: 'mm', format: 'a4' })
  const pageWidth = doc.internal.pageSize.getWidth()
  const now = new Date()
  const formattedDate = now.toLocaleDateString('fr-FR', { day: '2-digit', month: 'long', year: 'numeric' })
  const formattedTime = now.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })

  // Header bar
  doc.setFillColor(37, 99, 235)
  doc.rect(0, 0, pageWidth, 30, 'F')
  doc.setTextColor(255, 255, 255)
  doc.setFontSize(18)
  doc.setFont('helvetica', 'bold')
  doc.text('TaxCollect — Rapport de Productivite', 14, 14)
  doc.setFontSize(10)
  doc.setFont('helvetica', 'normal')
  doc.text(`Genere le ${formattedDate} a ${formattedTime}`, 14, 22)

  // Period
  doc.setTextColor(100, 100, 100)
  doc.setFontSize(9)
  const periodText = dateRange
    ? `Periode: ${new Date(dateRange.debut).toLocaleDateString('fr-FR')} - ${new Date(dateRange.fin).toLocaleDateString('fr-FR')}`
    : 'Periode: Toutes les donnees'
  doc.text(periodText, 14, 38)

  // Section 1: Summary KPIs
  doc.setTextColor(0, 0, 0)
  doc.setFontSize(13)
  doc.setFont('helvetica', 'bold')
  doc.text('1. Resume general', 14, 48)

  const totalCollected = agents.reduce((s, a) => s + (a.totalAmount || 0), 0)
  const totalTransactions = agents.reduce((s, a) => s + (a.transactionCount || 0), 0)
  const avgPerAgent = agents.length > 0 ? totalCollected / agents.length : 0

  autoTable(doc, {
    startY: 52,
    head: [['Indicateur', 'Valeur']],
    body: [
      ['Agents actifs', String(agents.length)],
      ['Total collecte', formatCurrency(totalCollected)],
      ['Total transactions', String(totalTransactions)],
      ['Montant moyen par agent', formatCurrency(avgPerAgent)],
      ...(recensementStats ? [
        ['Total contribuables', String(recensementStats.totalContribuables || 0)],
        ['Contribuables en validation', String(recensementStats.enValidation || 0)],
        ['Taux de synchronisation', `${(recensementStats.tauxSynchronisation || 0).toFixed(1)}%`],
      ] : []),
    ],
    theme: 'striped',
    headStyles: { fillColor: [37, 99, 235], fontSize: 10 },
    bodyStyles: { fontSize: 10 },
    margin: { left: 14, right: 14 },
  })

  // Section 2: Agent performance table
  let y = doc.lastAutoTable.finalY + 10
  doc.setFontSize(13)
  doc.setFont('helvetica', 'bold')
  doc.text('2. Performance par agent', 14, y)

  const sortedAgents = [...agents].sort((a, b) => (b.totalAmount || 0) - (a.totalAmount || 0))

  autoTable(doc, {
    startY: y + 4,
    head: [['Agent', 'Transactions', 'Total collecte', 'Montant moyen', 'Especes', 'Mobile Money']],
    body: sortedAgents.map(a => [
      `${a.nom || ''} ${a.prenom || ''}`,
      String(a.transactionCount || 0),
      formatCurrency(a.totalAmount || 0),
      formatCurrency(a.avgAmount || 0),
      formatCurrency(a.cashAmount || 0),
      formatCurrency(a.mobileMoneyAmount || 0),
    ]),
    theme: 'grid',
    headStyles: { fillColor: [37, 99, 235], fontSize: 9 },
    bodyStyles: { fontSize: 9 },
    margin: { left: 14, right: 14 },
    columnStyles: {
      0: { cellWidth: 40 },
    },
  })

  // Section 3: Zone distribution (if available)
  if (recensementStats && recensementStats.repartitionParZone) {
    y = doc.lastAutoTable.finalY + 10
    if (y > 250) {
      doc.addPage()
      y = 20
    }
    doc.setFontSize(13)
    doc.setFont('helvetica', 'bold')
    doc.text('3. Repartition des contribuables par zone', 14, y)

    const zoneEntries = Object.entries(recensementStats.repartitionParZone)
      .sort((a, b) => b[1] - a[1])

    autoTable(doc, {
      startY: y + 4,
      head: [['Zone', 'Contribuables', 'Part (%)']],
      body: zoneEntries.map(([zone, count]) => [
        zone,
        String(count),
        recensementStats.totalContribuables > 0
          ? `${((count / recensementStats.totalContribuables) * 100).toFixed(1)}%`
          : '0%',
      ]),
      theme: 'striped',
      headStyles: { fillColor: [16, 185, 129], fontSize: 10 },
      bodyStyles: { fontSize: 10 },
      margin: { left: 14, right: 14 },
    })
  }

  // Footer on each page
  const pageCount = doc.internal.getNumberOfPages()
  for (let i = 1; i <= pageCount; i++) {
    doc.setPage(i)
    const pageHeight = doc.internal.pageSize.getHeight()
    doc.setFontSize(8)
    doc.setTextColor(150, 150, 150)
    doc.text(
      `TaxCollect | Page ${i}/${pageCount} | Genere le ${formattedDate}`,
      14,
      pageHeight - 8
    )
  }

  // Save
  const filename = `rapport_productivite_${now.getFullYear()}${String(now.getMonth() + 1).padStart(2, '0')}${String(now.getDate()).padStart(2, '0')}.pdf`
  doc.save(filename)
}

function formatCurrency(amount) {
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: 'XOF',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0,
  }).format(amount || 0)
}
