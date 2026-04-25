'use client'

import { useState } from 'react'
import {
  LayoutDashboard,
  Camera,
  AlertTriangle,
  MessageCircle,
  CreditCard,
} from 'lucide-react'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { AppProvider } from '@/lib/app-context'
import { Navbar } from '@/components/navbar'
import { Dashboard } from '@/components/dashboard'
import { PrescriptionScanner } from '@/components/prescription-scanner'
import { EmergencyPanel } from '@/components/emergency-panel'
import { ChatInterface } from '@/components/chat-interface'
import { HealthCard } from '@/components/health-card'

const tabs = [
  { id: 'dashboard', label: 'Dashboard', icon: LayoutDashboard },
  { id: 'prescription', label: 'Prescription', icon: Camera },
  { id: 'emergency', label: 'Emergency', icon: AlertTriangle },
  { id: 'chat', label: 'Chat', icon: MessageCircle },
  { id: 'health-card', label: 'Health Card', icon: CreditCard },
]

function MedbridgeApp() {
  const [activeTab, setActiveTab] = useState('dashboard')

  const handleNavigate = (tab: string) => {
    setActiveTab(tab)
  }

  return (
    <div className="min-h-screen bg-background">
      <Navbar />
      <main className="container mx-auto px-4 py-6">
        <Tabs value={activeTab} onValueChange={setActiveTab} className="space-y-6">
          <TabsList className="grid w-full grid-cols-5">
            {tabs.map((tab) => (
              <TabsTrigger
                key={tab.id}
                value={tab.id}
                className="gap-2 data-[state=active]:bg-primary data-[state=active]:text-primary-foreground"
              >
                <tab.icon className="h-4 w-4" />
                <span className="hidden sm:inline">{tab.label}</span>
              </TabsTrigger>
            ))}
          </TabsList>

          <TabsContent value="dashboard" className="mt-6">
            <Dashboard onNavigate={handleNavigate} />
          </TabsContent>

          <TabsContent value="prescription" className="mt-6">
            <PrescriptionScanner />
          </TabsContent>

          <TabsContent value="emergency" className="mt-6">
            <EmergencyPanel />
          </TabsContent>

          <TabsContent value="chat" className="mt-6">
            <ChatInterface />
          </TabsContent>

          <TabsContent value="health-card" className="mt-6">
            <HealthCard />
          </TabsContent>
        </Tabs>
      </main>
    </div>
  )
}

export default function Page() {
  return (
    <AppProvider>
      <MedbridgeApp />
    </AppProvider>
  )
}
