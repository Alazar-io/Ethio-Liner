export interface User {
  name: string
  age: number
  gender: 'Male' | 'Female' | 'Other'
  condition?: string
  medications: string[]
  medicalHistory: MedicalHistoryItem[]
  prescriptions: Prescription[]
  menstrualData?: MenstrualData
}

export interface MedicalHistoryItem {
  id: string
  date: string
  description: string
  type: 'diagnosis' | 'procedure' | 'vaccination' | 'allergy'
}

export interface Prescription {
  id: string
  drugName: string
  dosage: string
  frequency: string
  instructions: string
  prescribedDate: string
  prescribedBy: string
  confidenceScore?: number
}

export interface MenstrualData {
  lastPeriodDate: string
  cycleLength: number
}

export interface ChatMessage {
  id: string
  role: 'user' | 'assistant'
  content: string
  timestamp: Date
}

export interface AgentThought {
  id: string
  type: 'analyzing' | 'tool' | 'thinking' | 'complete'
  content: string
  toolName?: string
}

export interface AgentResponse {
  severity: 'Low' | 'Medium' | 'High'
  reason: string
  recommendation: string
  emergencyAction?: string
  thoughts: AgentThought[]
  toolsUsed: string[]
}

export interface EmergencyCondition {
  id: string
  name: string
  icon: string
  steps: string[]
  urgencyLevel: 'critical' | 'high' | 'medium'
}

export interface ScannedPrescription {
  drugName: string
  dosage: string
  frequency: string
  instructions: string
  confidenceScore: number
}
