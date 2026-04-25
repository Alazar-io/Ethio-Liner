'use client'

import { useState } from 'react'
import {
  User,
  Calendar,
  Pill,
  FileText,
  Plus,
  Edit3,
  Save,
  X,
  Activity,
  Building2,
  Stethoscope,
  AlertCircle,
} from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Input } from '@/components/ui/input'
import { Textarea } from '@/components/ui/textarea'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog'
import { Label } from '@/components/ui/label'
import { useApp } from '@/lib/app-context'
import { CycleTracker } from './cycle-tracker'

export function HealthCard() {
  const { selectedPatient, role, addNote, addPrescription, updatePatientField } = useApp()
  const [newNote, setNewNote] = useState('')
  const [isEditing, setIsEditing] = useState(false)
  const [editedCondition, setEditedCondition] = useState('')
  const [prescriptionDialogOpen, setPrescriptionDialogOpen] = useState(false)
  const [newPrescription, setNewPrescription] = useState({
    drugName: '',
    dosage: '',
    frequency: '',
    instructions: '',
  })

  if (!selectedPatient) {
    return (
      <div className="flex h-64 items-center justify-center">
        <p className="text-muted-foreground">No patient selected</p>
      </div>
    )
  }

  const handleAddNote = () => {
    if (newNote.trim()) {
      addNote(newNote)
      setNewNote('')
    }
  }

  const handleSaveCondition = () => {
    if (editedCondition.trim()) {
      updatePatientField('condition', editedCondition)
      setIsEditing(false)
    }
  }

  const handleAddPrescription = () => {
    if (newPrescription.drugName && newPrescription.dosage && newPrescription.frequency) {
      addPrescription(newPrescription)
      setNewPrescription({ drugName: '', dosage: '', frequency: '', instructions: '' })
      setPrescriptionDialogOpen(false)
    }
  }

  const startEditing = () => {
    setEditedCondition(selectedPatient.condition)
    setIsEditing(true)
  }

  const getMedicalHistoryIcon = (type: string) => {
    switch (type) {
      case 'diagnosis':
        return <Activity className="h-4 w-4 text-primary" />
      case 'procedure':
        return <Stethoscope className="h-4 w-4 text-blue-500" />
      case 'vaccination':
        return <Pill className="h-4 w-4 text-emerald-500" />
      case 'allergy':
        return <AlertCircle className="h-4 w-4 text-amber-500" />
      default:
        return <FileText className="h-4 w-4 text-muted-foreground" />
    }
  }

  return (
    <div className="space-y-6">
      {role === 'patient' && (
        <div className="rounded-lg border border-border bg-secondary/30 px-4 py-2">
          <p className="text-sm text-muted-foreground">
            <span className="mr-2 inline-block h-2 w-2 rounded-full bg-amber-500" />
            View Only Mode - Contact your healthcare provider to update your records
          </p>
        </div>
      )}

      <Card>
        <CardHeader>
          <div className="flex items-start justify-between">
            <div className="flex items-center gap-4">
              <div className="flex h-16 w-16 items-center justify-center rounded-2xl bg-primary/10">
                <User className="h-8 w-8 text-primary" />
              </div>
              <div>
                <CardTitle className="text-2xl">{selectedPatient.name}</CardTitle>
                <CardDescription className="mt-1">
                  {selectedPatient.age} years old | {selectedPatient.gender}
                </CardDescription>
              </div>
            </div>
            <div className="text-right">
              {isEditing ? (
                <div className="flex items-center gap-2">
                  <Input
                    value={editedCondition}
                    onChange={(e) => setEditedCondition(e.target.value)}
                    className="w-40"
                  />
                  <Button size="sm" onClick={handleSaveCondition}>
                    <Save className="h-4 w-4" />
                  </Button>
                  <Button size="sm" variant="ghost" onClick={() => setIsEditing(false)}>
                    <X className="h-4 w-4" />
                  </Button>
                </div>
              ) : (
                <div className="flex items-center gap-2">
                  <Badge variant="secondary" className="bg-primary/10 text-primary">
                    {selectedPatient.condition}
                  </Badge>
                  {role === 'doctor' && (
                    <Button size="sm" variant="ghost" onClick={startEditing}>
                      <Edit3 className="h-4 w-4" />
                    </Button>
                  )}
                </div>
              )}
            </div>
          </div>
        </CardHeader>
        <CardContent>
          <div className="grid gap-4 sm:grid-cols-2">
            <div className="flex items-center gap-3 rounded-lg border border-border bg-muted/30 p-3">
              <Stethoscope className="h-5 w-5 text-muted-foreground" />
              <div>
                <p className="text-sm text-muted-foreground">Primary Doctor</p>
                <p className="font-medium text-foreground">{selectedPatient.doctor}</p>
              </div>
            </div>
            <div className="flex items-center gap-3 rounded-lg border border-border bg-muted/30 p-3">
              <Building2 className="h-5 w-5 text-muted-foreground" />
              <div>
                <p className="text-sm text-muted-foreground">Hospital</p>
                <p className="font-medium text-foreground">{selectedPatient.hospital}</p>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      <Tabs defaultValue="history" className="space-y-4">
        <TabsList className="grid w-full grid-cols-4">
          <TabsTrigger value="history">History</TabsTrigger>
          <TabsTrigger value="prescriptions">Prescriptions</TabsTrigger>
          <TabsTrigger value="notes">Notes</TabsTrigger>
          {selectedPatient.gender === 'Female' && selectedPatient.menstrualData && (
            <TabsTrigger value="cycle">Cycle</TabsTrigger>
          )}
        </TabsList>

        <TabsContent value="history">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-lg">
                <Calendar className="h-5 w-5 text-primary" />
                Medical History
              </CardTitle>
            </CardHeader>
            <CardContent>
              {selectedPatient.medicalHistory.length === 0 ? (
                <p className="text-sm text-muted-foreground">No medical history records</p>
              ) : (
                <div className="space-y-3">
                  {selectedPatient.medicalHistory.map((item) => (
                    <div
                      key={item.id}
                      className="flex items-start gap-3 rounded-lg border border-border p-4"
                    >
                      <div className="mt-0.5">{getMedicalHistoryIcon(item.type)}</div>
                      <div className="flex-1">
                        <div className="flex items-center justify-between">
                          <p className="font-medium text-foreground">{item.description}</p>
                          <Badge variant="outline" className="text-xs">
                            {item.type}
                          </Badge>
                        </div>
                        <p className="mt-1 text-sm text-muted-foreground">{item.date}</p>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="prescriptions">
          <Card>
            <CardHeader>
              <div className="flex items-center justify-between">
                <CardTitle className="flex items-center gap-2 text-lg">
                  <Pill className="h-5 w-5 text-primary" />
                  Prescriptions
                </CardTitle>
                {role === 'doctor' && (
                  <Dialog open={prescriptionDialogOpen} onOpenChange={setPrescriptionDialogOpen}>
                    <DialogTrigger asChild>
                      <Button size="sm" className="gap-2">
                        <Plus className="h-4 w-4" />
                        Add Prescription
                      </Button>
                    </DialogTrigger>
                    <DialogContent>
                      <DialogHeader>
                        <DialogTitle>Add New Prescription</DialogTitle>
                        <DialogDescription>
                          Enter the prescription details for {selectedPatient.name}
                        </DialogDescription>
                      </DialogHeader>
                      <div className="grid gap-4 py-4">
                        <div className="grid gap-2">
                          <Label htmlFor="drugName">Drug Name</Label>
                          <Input
                            id="drugName"
                            value={newPrescription.drugName}
                            onChange={(e) =>
                              setNewPrescription({ ...newPrescription, drugName: e.target.value })
                            }
                            placeholder="e.g., Amoxicillin"
                          />
                        </div>
                        <div className="grid grid-cols-2 gap-4">
                          <div className="grid gap-2">
                            <Label htmlFor="dosage">Dosage</Label>
                            <Input
                              id="dosage"
                              value={newPrescription.dosage}
                              onChange={(e) =>
                                setNewPrescription({ ...newPrescription, dosage: e.target.value })
                              }
                              placeholder="e.g., 500mg"
                            />
                          </div>
                          <div className="grid gap-2">
                            <Label htmlFor="frequency">Frequency</Label>
                            <Input
                              id="frequency"
                              value={newPrescription.frequency}
                              onChange={(e) =>
                                setNewPrescription({ ...newPrescription, frequency: e.target.value })
                              }
                              placeholder="e.g., Twice daily"
                            />
                          </div>
                        </div>
                        <div className="grid gap-2">
                          <Label htmlFor="instructions">Instructions</Label>
                          <Textarea
                            id="instructions"
                            value={newPrescription.instructions}
                            onChange={(e) =>
                              setNewPrescription({ ...newPrescription, instructions: e.target.value })
                            }
                            placeholder="Special instructions for taking this medication"
                          />
                        </div>
                      </div>
                      <DialogFooter>
                        <Button variant="outline" onClick={() => setPrescriptionDialogOpen(false)}>
                          Cancel
                        </Button>
                        <Button onClick={handleAddPrescription}>Add Prescription</Button>
                      </DialogFooter>
                    </DialogContent>
                  </Dialog>
                )}
              </div>
            </CardHeader>
            <CardContent>
              {selectedPatient.prescriptions.length === 0 ? (
                <p className="text-sm text-muted-foreground">No prescriptions</p>
              ) : (
                <div className="space-y-3">
                  {selectedPatient.prescriptions.map((rx) => (
                    <div key={rx.id} className="rounded-lg border border-border p-4">
                      <div className="flex items-start justify-between">
                        <div>
                          <p className="text-lg font-semibold text-foreground">{rx.drugName}</p>
                          <p className="text-sm text-muted-foreground">
                            {rx.dosage} - {rx.frequency}
                          </p>
                        </div>
                        <Badge variant="outline">{rx.prescribedDate}</Badge>
                      </div>
                      <p className="mt-2 text-sm text-foreground">{rx.instructions}</p>
                      <p className="mt-2 text-xs text-muted-foreground">
                        Prescribed by {rx.prescribedBy}
                      </p>
                    </div>
                  ))}
                </div>
              )}
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="notes">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-lg">
                <FileText className="h-5 w-5 text-primary" />
                Clinical Notes
              </CardTitle>
              {role === 'patient' && (
                <CardDescription>Notes are view-only for patients</CardDescription>
              )}
            </CardHeader>
            <CardContent className="space-y-4">
              {role === 'doctor' && (
                <div className="space-y-2">
                  <Textarea
                    value={newNote}
                    onChange={(e) => setNewNote(e.target.value)}
                    placeholder="Add a clinical note..."
                    className="min-h-[100px]"
                  />
                  <Button onClick={handleAddNote} disabled={!newNote.trim()} className="gap-2">
                    <Plus className="h-4 w-4" />
                    Add Note
                  </Button>
                </div>
              )}

              {selectedPatient.notes.length === 0 ? (
                <p className="text-sm text-muted-foreground">No clinical notes</p>
              ) : (
                <div className="space-y-3">
                  {selectedPatient.notes.map((note) => (
                    <div key={note.id} className="rounded-lg border border-border bg-muted/30 p-4">
                      <p className="text-foreground">{note.content}</p>
                      <div className="mt-2 flex items-center justify-between text-xs text-muted-foreground">
                        <span>{note.author}</span>
                        <span>{note.date}</span>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </CardContent>
          </Card>
        </TabsContent>

        {selectedPatient.gender === 'Female' && selectedPatient.menstrualData && (
          <TabsContent value="cycle">
            <CycleTracker
              lastPeriodDate={selectedPatient.menstrualData.lastPeriodDate}
              cycleLength={selectedPatient.menstrualData.cycleLength}
            />
          </TabsContent>
        )}
      </Tabs>
    </div>
  )
}
