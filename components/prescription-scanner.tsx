'use client'

import { useState, useRef } from 'react'
import {
  Upload,
  Camera,
  FileText,
  Sparkles,
  Save,
  CheckCircle2,
  AlertCircle,
} from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Progress } from '@/components/ui/progress'
import { useApp } from '@/lib/app-context'
import type { ScannedPrescription } from '@/lib/types'

const mockScannedResults: ScannedPrescription[] = [
  {
    drugName: 'Amoxicillin',
    dosage: '500mg',
    frequency: 'Three times daily',
    instructions: 'Take with food. Complete full course of antibiotics.',
    confidenceScore: 94,
  },
  {
    drugName: 'Ibuprofen',
    dosage: '400mg',
    frequency: 'Every 6 hours as needed',
    instructions: 'Take with food or milk. Do not exceed 1200mg in 24 hours.',
    confidenceScore: 87,
  },
  {
    drugName: 'Omeprazole',
    dosage: '20mg',
    frequency: 'Once daily before breakfast',
    instructions: 'Take 30 minutes before eating. Do not crush or chew.',
    confidenceScore: 91,
  },
]

export function PrescriptionScanner() {
  const { addPrescription } = useApp()
  const [isScanning, setIsScanning] = useState(false)
  const [scanProgress, setScanProgress] = useState(0)
  const [scannedResult, setScannedResult] = useState<ScannedPrescription | null>(null)
  const [simplified, setSimplified] = useState<string | null>(null)
  const [saved, setSaved] = useState(false)
  const fileInputRef = useRef<HTMLInputElement>(null)

  const handleUpload = () => {
    fileInputRef.current?.click()
  }

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (file) {
      simulateScan()
    }
  }

  const simulateScan = () => {
    setIsScanning(true)
    setScanProgress(0)
    setScannedResult(null)
    setSimplified(null)
    setSaved(false)

    const interval = setInterval(() => {
      setScanProgress((prev) => {
        if (prev >= 100) {
          clearInterval(interval)
          setIsScanning(false)
          const randomResult = mockScannedResults[Math.floor(Math.random() * mockScannedResults.length)]
          setScannedResult(randomResult)
          return 100
        }
        return prev + 10
      })
    }, 200)
  }

  const handleExplainSimply = () => {
    if (!scannedResult) return

    setSimplified(`**${scannedResult.drugName}** is a medication that helps your body fight infection/inflammation/manage your condition.

**How to take it:**
- Take ${scannedResult.dosage} ${scannedResult.frequency.toLowerCase()}
- ${scannedResult.instructions}

**Important reminders:**
- Don't skip doses
- Store at room temperature
- Contact your doctor if you experience unusual side effects

This explanation is simplified for general understanding. Always follow your doctor's specific instructions.`)
  }

  const handleSaveToRecord = () => {
    if (!scannedResult) return

    addPrescription({
      drugName: scannedResult.drugName,
      dosage: scannedResult.dosage,
      frequency: scannedResult.frequency,
      instructions: scannedResult.instructions,
    })
    setSaved(true)
  }

  const getConfidenceColor = (score: number) => {
    if (score >= 90) return 'text-emerald-600 bg-emerald-50'
    if (score >= 75) return 'text-amber-600 bg-amber-50'
    return 'text-red-600 bg-red-50'
  }

  return (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Camera className="h-5 w-5 text-primary" />
            Prescription Scanner
          </CardTitle>
          <CardDescription>
            Upload a prescription image to extract medication details using AI OCR
          </CardDescription>
        </CardHeader>
        <CardContent>
          <input
            ref={fileInputRef}
            type="file"
            accept="image/*"
            className="hidden"
            onChange={handleFileChange}
          />

          {!scannedResult && !isScanning && (
            <div
              className="flex cursor-pointer flex-col items-center justify-center gap-4 rounded-xl border-2 border-dashed border-border bg-muted/30 p-12 transition-colors hover:border-primary/50 hover:bg-muted/50"
              onClick={handleUpload}
            >
              <div className="flex h-16 w-16 items-center justify-center rounded-full bg-primary/10">
                <Upload className="h-8 w-8 text-primary" />
              </div>
              <div className="text-center">
                <p className="font-medium text-foreground">Upload Prescription Image</p>
                <p className="text-sm text-muted-foreground">
                  Click or drag and drop an image file
                </p>
              </div>
              <Button variant="outline" size="sm">
                <FileText className="mr-2 h-4 w-4" />
                Choose File
              </Button>
            </div>
          )}

          {isScanning && (
            <div className="space-y-4 py-8 text-center">
              <div className="mx-auto flex h-16 w-16 animate-pulse items-center justify-center rounded-full bg-primary/10">
                <Sparkles className="h-8 w-8 text-primary" />
              </div>
              <div>
                <p className="font-medium text-foreground">Analyzing Prescription...</p>
                <p className="text-sm text-muted-foreground">
                  Using AI to extract medication details
                </p>
              </div>
              <div className="mx-auto max-w-xs">
                <Progress value={scanProgress} className="h-2" />
                <p className="mt-2 text-sm text-muted-foreground">{scanProgress}% complete</p>
              </div>
            </div>
          )}
        </CardContent>
      </Card>

      {scannedResult && (
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <CardTitle className="flex items-center gap-2 text-lg">
                <CheckCircle2 className="h-5 w-5 text-emerald-600" />
                Extracted Information
              </CardTitle>
              <Badge className={getConfidenceColor(scannedResult.confidenceScore)}>
                {scannedResult.confidenceScore}% Confidence
              </Badge>
            </div>
          </CardHeader>
          <CardContent className="space-y-6">
            <div className="grid gap-4 sm:grid-cols-2">
              <div className="rounded-lg border border-border bg-muted/30 p-4">
                <p className="text-sm font-medium text-muted-foreground">Drug Name</p>
                <p className="text-lg font-semibold text-foreground">{scannedResult.drugName}</p>
              </div>
              <div className="rounded-lg border border-border bg-muted/30 p-4">
                <p className="text-sm font-medium text-muted-foreground">Dosage</p>
                <p className="text-lg font-semibold text-foreground">{scannedResult.dosage}</p>
              </div>
              <div className="rounded-lg border border-border bg-muted/30 p-4">
                <p className="text-sm font-medium text-muted-foreground">Frequency</p>
                <p className="text-lg font-semibold text-foreground">{scannedResult.frequency}</p>
              </div>
              <div className="rounded-lg border border-border bg-muted/30 p-4">
                <p className="text-sm font-medium text-muted-foreground">Instructions</p>
                <p className="text-foreground">{scannedResult.instructions}</p>
              </div>
            </div>

            <div className="flex flex-wrap gap-3">
              <Button onClick={handleExplainSimply} variant="outline" className="gap-2">
                <Sparkles className="h-4 w-4" />
                Explain Simply
              </Button>
              <Button
                onClick={handleSaveToRecord}
                disabled={saved}
                className="gap-2"
              >
                {saved ? (
                  <>
                    <CheckCircle2 className="h-4 w-4" />
                    Saved to Record
                  </>
                ) : (
                  <>
                    <Save className="h-4 w-4" />
                    Save to Health Record
                  </>
                )}
              </Button>
              <Button variant="ghost" onClick={handleUpload}>
                Scan Another
              </Button>
            </div>

            {simplified && (
              <div className="rounded-lg border border-primary/20 bg-primary/5 p-4">
                <div className="mb-2 flex items-center gap-2">
                  <AlertCircle className="h-4 w-4 text-primary" />
                  <span className="font-medium text-primary">Simple Explanation</span>
                </div>
                <div className="prose prose-sm max-w-none text-foreground">
                  {simplified.split('\n').map((line, i) => (
                    <p key={i} className="my-1">
                      {line.startsWith('**') ? (
                        <strong>{line.replace(/\*\*/g, '')}</strong>
                      ) : line.startsWith('-') ? (
                        <span className="ml-4 block">{line}</span>
                      ) : (
                        line
                      )}
                    </p>
                  ))}
                </div>
              </div>
            )}
          </CardContent>
        </Card>
      )}
    </div>
  )
}
