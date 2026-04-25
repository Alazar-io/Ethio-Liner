import type { Patient, EmergencyCondition } from './types'

export const patients: Patient[] = [
  {
    id: '1',
    name: 'Sarah Johnson',
    age: 32,
    gender: 'Female',
    condition: 'Type 2 Diabetes',
    medications: ['Metformin 500mg', 'Lisinopril 10mg'],
    doctor: 'Dr. Emily Chen',
    hospital: 'City General Hospital',
    medicalHistory: [
      { id: '1', date: '2024-01-15', description: 'Diagnosed with Type 2 Diabetes', type: 'diagnosis' },
      { id: '2', date: '2023-06-20', description: 'Annual flu vaccination', type: 'vaccination' },
      { id: '3', date: '2022-11-10', description: 'Penicillin allergy identified', type: 'allergy' },
    ],
    prescriptions: [
      {
        id: '1',
        drugName: 'Metformin',
        dosage: '500mg',
        frequency: 'Twice daily',
        instructions: 'Take with meals. Monitor blood sugar levels.',
        prescribedDate: '2024-01-15',
        prescribedBy: 'Dr. Emily Chen',
      },
      {
        id: '2',
        drugName: 'Lisinopril',
        dosage: '10mg',
        frequency: 'Once daily',
        instructions: 'Take in the morning. Monitor blood pressure.',
        prescribedDate: '2024-02-01',
        prescribedBy: 'Dr. Emily Chen',
      },
    ],
    notes: [
      { id: '1', date: '2024-03-01', content: 'Patient showing good progress with blood sugar management.', author: 'Dr. Emily Chen' },
    ],
    menstrualData: {
      lastPeriodDate: '2024-03-10',
      cycleLength: 28,
    },
  },
  {
    id: '2',
    name: 'James Williams',
    age: 58,
    gender: 'Male',
    condition: 'Hypertension',
    medications: ['Amlodipine 5mg', 'Aspirin 81mg'],
    doctor: 'Dr. Michael Roberts',
    hospital: 'Regional Medical Center',
    medicalHistory: [
      { id: '1', date: '2023-08-10', description: 'Diagnosed with Hypertension', type: 'diagnosis' },
      { id: '2', date: '2023-09-15', description: 'Cardiac stress test - normal', type: 'procedure' },
      { id: '3', date: '2022-03-20', description: 'Sulfa drug allergy', type: 'allergy' },
    ],
    prescriptions: [
      {
        id: '1',
        drugName: 'Amlodipine',
        dosage: '5mg',
        frequency: 'Once daily',
        instructions: 'Take at the same time each day.',
        prescribedDate: '2023-08-10',
        prescribedBy: 'Dr. Michael Roberts',
      },
      {
        id: '2',
        drugName: 'Aspirin',
        dosage: '81mg',
        frequency: 'Once daily',
        instructions: 'Take with food to reduce stomach upset.',
        prescribedDate: '2023-08-10',
        prescribedBy: 'Dr. Michael Roberts',
      },
    ],
    notes: [
      { id: '1', date: '2024-02-15', content: 'Blood pressure well controlled. Continue current regimen.', author: 'Dr. Michael Roberts' },
    ],
  },
  {
    id: '3',
    name: 'Maria Garcia',
    age: 45,
    gender: 'Female',
    condition: 'Asthma',
    medications: ['Albuterol Inhaler', 'Fluticasone 250mcg'],
    doctor: 'Dr. Sarah Thompson',
    hospital: 'Community Health Clinic',
    medicalHistory: [
      { id: '1', date: '2020-05-10', description: 'Asthma diagnosis', type: 'diagnosis' },
      { id: '2', date: '2023-10-01', description: 'Pulmonary function test', type: 'procedure' },
      { id: '3', date: '2021-07-15', description: 'COVID-19 vaccination completed', type: 'vaccination' },
    ],
    prescriptions: [
      {
        id: '1',
        drugName: 'Albuterol',
        dosage: '90mcg',
        frequency: 'As needed',
        instructions: 'Use for acute symptoms. Max 4 puffs every 4 hours.',
        prescribedDate: '2024-01-20',
        prescribedBy: 'Dr. Sarah Thompson',
      },
      {
        id: '2',
        drugName: 'Fluticasone',
        dosage: '250mcg',
        frequency: 'Twice daily',
        instructions: 'Rinse mouth after use to prevent thrush.',
        prescribedDate: '2024-01-20',
        prescribedBy: 'Dr. Sarah Thompson',
      },
    ],
    notes: [
      { id: '1', date: '2024-01-20', content: 'Asthma well controlled. No recent exacerbations.', author: 'Dr. Sarah Thompson' },
    ],
    menstrualData: {
      lastPeriodDate: '2024-03-05',
      cycleLength: 30,
    },
  },
]

export const emergencyConditions: EmergencyCondition[] = [
  {
    id: 'heart-attack',
    name: 'Heart Attack',
    icon: 'Heart',
    urgencyLevel: 'critical',
    steps: [
      'Call emergency services (911) immediately',
      'Have the person sit or lie down in a comfortable position',
      'Loosen any tight clothing around chest and neck',
      'If prescribed, help them take nitroglycerin',
      'If available and not allergic, give aspirin (325mg) to chew',
      'If the person becomes unresponsive, begin CPR',
      'Use an AED if available and follow its instructions',
      'Stay with the person until help arrives',
    ],
  },
  {
    id: 'bleeding',
    name: 'Severe Bleeding',
    icon: 'Droplets',
    urgencyLevel: 'critical',
    steps: [
      'Call emergency services (911) for severe bleeding',
      'Put on gloves if available to protect yourself',
      'Apply firm, direct pressure to the wound with a clean cloth',
      'Keep applying pressure - do not remove the cloth',
      'If blood soaks through, add more cloth on top',
      'Elevate the injured area above the heart if possible',
      'For limb injuries, apply a tourniquet if bleeding is life-threatening',
      'Keep the person warm and calm until help arrives',
    ],
  },
  {
    id: 'fainting',
    name: 'Fainting',
    icon: 'User',
    urgencyLevel: 'high',
    steps: [
      'Help the person lie down flat on their back',
      'Elevate their legs about 12 inches if no injury is suspected',
      'Loosen any tight clothing, belts, or collars',
      'Check for breathing and pulse',
      'Turn them on their side if they vomit',
      'Do not give them anything to eat or drink',
      'Keep them lying down for at least 10-15 minutes',
      'Call 911 if they do not regain consciousness within 1 minute',
    ],
  },
]

export const mockAIResponses: Record<string, string> = {
  'explain my medication': `Based on your current prescriptions, here's what you need to know:

**Your Medications:**
1. **Primary medication** - This helps manage your condition by regulating key bodily functions. Take it exactly as prescribed.

2. **Supporting medication** - This works alongside your primary medication to provide comprehensive care.

**Important Tips:**
- Take medications at the same time each day
- Don't skip doses even if you feel better
- Report any side effects to your doctor
- Keep a medication diary

Would you like more specific information about any of these medications?`,

  'emergency help': `**Emergency Resources:**

For life-threatening emergencies, call **911** immediately.

**When to seek emergency care:**
- Chest pain or difficulty breathing
- Severe bleeding that won't stop
- Loss of consciousness
- Signs of stroke (face drooping, arm weakness, speech difficulty)
- Severe allergic reactions

**For non-emergency medical advice:**
- Contact your primary care physician
- Visit an urgent care clinic
- Use the Emergency tab in this app for first aid guidance

Is there a specific emergency situation you need help with?`,

  'dosage info': `**Understanding Your Dosage:**

Your medications are prescribed at specific doses for a reason. Here's what to know:

**Key Points:**
- Never change your dose without consulting your doctor
- If you miss a dose, take it as soon as you remember (unless it's almost time for the next dose)
- Never double up on doses
- Store medications as directed (some need refrigeration)

**Signs your dose may need adjustment:**
- Symptoms not improving
- New side effects
- Changes in other health conditions

Would you like to discuss any specific concerns about your medication dosages?`,

  default: `I understand you have a health-related question. While I can provide general information, please remember that this is not a substitute for professional medical advice.

For your specific concern, I recommend:
1. Consulting with your healthcare provider
2. Reviewing your current medications and health records
3. Using the Emergency tab if you need immediate guidance

How can I help you further?`,
}
