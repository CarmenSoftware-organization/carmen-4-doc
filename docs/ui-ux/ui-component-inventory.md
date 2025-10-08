# Carmen.NET UI Component Inventory

**Document Version:** 1.0
**Last Updated:** October 6, 2025
**Target Audience:** UI/UX Designers, Frontend Developers, Product Managers
**Prerequisites:** Functional Requirements, API Documentation

---

## Table of Contents

1. [UI Architecture Overview](#ui-architecture-overview)
2. [Component Categories](#component-categories)
3. [Layout Components](#layout-components)
4. [Data Display Components](#data-display-components)
5. [Form Components](#form-components)
6. [Navigation Components](#navigation-components)
7. [Feedback Components](#feedback-components)
8. [Business Components](#business-components)
9. [Component Design Patterns](#component-design-patterns)

---

## 1. UI Architecture Overview

### Current Architecture

Carmen.NET uses a **hybrid architecture**:

```
┌─────────────────────────────────────────────┐
│   Carmen.WebSupport (MVC Views)              │  ← Legacy UI (Admin)
├─────────────────────────────────────────────┤
│   Carmen.WebApi (RESTful API)                │  ← API Layer
├─────────────────────────────────────────────┤
│   Modern Frontend (Recommended)              │  ← React/Vue/Angular
│   - Component-based architecture             │
│   - API-driven data fetching                 │
│   - Real-time updates (SignalR)              │
└─────────────────────────────────────────────┘
```

**Technology Stack (Recommended):**
- **Framework**: React 18+ with TypeScript
- **UI Library**: Material-UI (MUI) or Ant Design
- **State Management**: Redux Toolkit or Zustand
- **Forms**: React Hook Form + Zod validation
- **Data Tables**: TanStack Table (React Table v8)
- **Charts**: Recharts or Apache ECharts
- **HTTP Client**: Axios with interceptors
- **Real-time**: SignalR for progress notifications

### Design System

**Color Palette:**
```css
/* Primary Colors */
--primary-main: #1976D2;      /* Blue */
--primary-light: #42A5F5;
--primary-dark: #1565C0;

/* Secondary Colors */
--secondary-main: #9C27B0;    /* Purple */
--secondary-light: #BA68C8;
--secondary-dark: #7B1FA2;

/* Status Colors */
--success: #2E7D32;           /* Green */
--warning: #ED6C02;           /* Orange */
--error: #D32F2F;             /* Red */
--info: #0288D1;              /* Light Blue */

/* Neutral Colors */
--background: #FAFAFA;
--surface: #FFFFFF;
--text-primary: #212121;
--text-secondary: #757575;
--divider: #E0E0E0;
```

**Typography:**
```css
/* Font Family */
font-family: 'Roboto', 'Helvetica', 'Arial', sans-serif;

/* Headings */
h1: 2.5rem (40px) - bold
h2: 2rem (32px) - bold
h3: 1.75rem (28px) - semibold
h4: 1.5rem (24px) - semibold
h5: 1.25rem (20px) - medium
h6: 1rem (16px) - medium

/* Body Text */
body1: 1rem (16px) - regular
body2: 0.875rem (14px) - regular
caption: 0.75rem (12px) - regular
```

**Spacing System:**
```css
--spacing-1: 4px;
--spacing-2: 8px;
--spacing-3: 12px;
--spacing-4: 16px;
--spacing-5: 20px;
--spacing-6: 24px;
--spacing-8: 32px;
--spacing-10: 40px;
--spacing-12: 48px;
```

---

## 2. Component Categories

### Component Hierarchy

```
Application Components
├── Layout Components (Shell, Navigation)
├── Data Display (Tables, Lists, Cards)
├── Form Components (Inputs, Selects, Date Pickers)
├── Navigation (Menus, Breadcrumbs, Tabs)
├── Feedback (Alerts, Snackbars, Dialogs)
└── Business Components (Invoice Form, Payment Form)
```

### Component Naming Convention

```
{Domain}{Entity}{ComponentType}

Examples:
- ApInvoiceForm
- ApInvoiceTable
- ApInvoiceDetail
- VendorSelector
- AccountCodePicker
```

---

## 3. Layout Components

### 3.1 AppShell

**Purpose**: Main application layout with header, sidebar, and content area

**Props:**
```typescript
interface AppShellProps {
  children: React.ReactNode;
  user: ViewUserLogin;
  tenant: string;
  onLogout: () => void;
}
```

**Structure:**
```tsx
<AppShell>
  <AppHeader user={user} tenant={tenant} onLogout={onLogout} />
  <AppSidebar />
  <AppContent>
    {children}
  </AppContent>
  <AppFooter />
</AppShell>
```

**Features:**
- Collapsible sidebar (mobile responsive)
- User profile dropdown
- Tenant switcher
- Global search
- Notification center

---

### 3.2 AppHeader

**Purpose**: Top navigation bar with branding and user actions

**Components:**
```tsx
<AppHeader>
  <Logo />
  <TenantSelector currentTenant={tenant} />
  <GlobalSearch />
  <NotificationBell />
  <UserMenu user={user} onLogout={onLogout} />
</AppHeader>
```

**Responsive Behavior:**
- Desktop: Full horizontal layout
- Tablet: Collapsed search, hamburger menu
- Mobile: Minimal UI, drawer navigation

---

### 3.3 AppSidebar

**Purpose**: Primary navigation menu

**Menu Structure:**
```tsx
<AppSidebar>
  <NavSection title="Dashboard">
    <NavItem icon={<Dashboard />} label="Dashboard" path="/dashboard" />
  </NavSection>

  <NavSection title="Accounts Payable">
    <NavItem icon={<Invoice />} label="Invoices" path="/ap/invoices" />
    <NavItem icon={<Payment />} label="Payments" path="/ap/payments" />
    <NavItem icon={<Vendor />} label="Vendors" path="/ap/vendors" />
  </NavSection>

  <NavSection title="Accounts Receivable">
    <NavItem icon={<ReceivableInvoice />} label="Invoices" path="/ar/invoices" />
    <NavItem icon={<Receipt />} label="Receipts" path="/ar/receipts" />
    <NavItem icon={<Customer />} label="Customers" path="/ar/customers" />
  </NavSection>

  <NavSection title="General Ledger">
    <NavItem icon={<JournalVoucher />} label="Journal Vouchers" path="/gl/journal-vouchers" />
    <NavItem icon={<ChartOfAccounts />} label="Chart of Accounts" path="/gl/accounts" />
    <NavItem icon={<Reports />} label="Reports" path="/gl/reports" />
  </NavSection>

  <NavSection title="Administration">
    <NavItem icon={<Settings />} label="Settings" path="/admin/settings" />
    <NavItem icon={<Users />} label="Users" path="/admin/users" />
  </NavSection>
</AppSidebar>
```

---

### 3.4 Breadcrumbs

**Purpose**: Show current navigation path

**Example:**
```tsx
<Breadcrumbs>
  <BreadcrumbItem href="/dashboard">Dashboard</BreadcrumbItem>
  <BreadcrumbItem href="/ap">Accounts Payable</BreadcrumbItem>
  <BreadcrumbItem href="/ap/invoices">Invoices</BreadcrumbItem>
  <BreadcrumbItem current>INV-2025-001</BreadcrumbItem>
</Breadcrumbs>
```

---

## 4. Data Display Components

### 4.1 DataTable

**Purpose**: Paginated, sortable, filterable data grid

**Props:**
```typescript
interface DataTableProps<T> {
  columns: ColumnDef<T>[];
  data: T[];
  loading?: boolean;
  pagination?: PaginationState;
  sorting?: SortingState;
  filtering?: FilteringState;
  onPaginationChange?: (pagination: PaginationState) => void;
  onSortingChange?: (sorting: SortingState) => void;
  onRowClick?: (row: T) => void;
  actions?: RowAction<T>[];
}
```

**Features:**
- Server-side pagination
- Multi-column sorting
- Column filtering
- Row selection (single/multiple)
- Export to Excel/CSV
- Column visibility toggle
- Responsive layout (mobile stacking)

**Example Usage:**
```tsx
<DataTable
  columns={[
    { id: 'invoiceNumber', header: 'Invoice #', accessorKey: 'invoiceNumber' },
    { id: 'invoiceDate', header: 'Date', accessorKey: 'invoiceDate', cell: formatDate },
    { id: 'vendorName', header: 'Vendor', accessorKey: 'vendorName' },
    { id: 'totalAmount', header: 'Amount', accessorKey: 'totalAmount', cell: formatCurrency },
    { id: 'status', header: 'Status', accessorKey: 'status', cell: StatusBadge }
  ]}
  data={invoices}
  loading={loading}
  pagination={{ page: 1, pageSize: 50 }}
  onPaginationChange={handlePaginationChange}
  onRowClick={handleRowClick}
  actions={[
    { label: 'View', icon: <Eye />, onClick: handleView },
    { label: 'Edit', icon: <Edit />, onClick: handleEdit },
    { label: 'Delete', icon: <Delete />, onClick: handleDelete, confirm: true }
  ]}
/>
```

---

### 4.2 StatusBadge

**Purpose**: Visual status indicator

**Variants:**
```tsx
// Invoice Status
<StatusBadge status="Draft" color="default" />
<StatusBadge status="Pending Approval" color="warning" />
<StatusBadge status="Approved" color="info" />
<StatusBadge status="Posted" color="success" />
<StatusBadge status="Paid" color="success" />
<StatusBadge status="Void" color="error" />

// Payment Status
<StatusBadge status="Pending" color="warning" />
<StatusBadge status="Cleared" color="success" />
<StatusBadge status="Bounced" color="error" />
```

---

### 4.3 AmountDisplay

**Purpose**: Format and display monetary amounts

**Props:**
```typescript
interface AmountDisplayProps {
  amount: number;
  currency?: string;
  showSign?: boolean;
  colorCode?: boolean;  // Red for negative, green for positive
}
```

**Example:**
```tsx
<AmountDisplay amount={1070.50} currency="THB" />
// Output: ฿1,070.50

<AmountDisplay amount={-500} colorCode={true} />
// Output: <span style="color: red">-$500.00</span>
```

---

### 4.4 DetailCard

**Purpose**: Display entity details in card format

**Example:**
```tsx
<DetailCard title="Invoice Details">
  <DetailRow label="Invoice Number" value="INV-2025-001" />
  <DetailRow label="Invoice Date" value="2025-10-06" />
  <DetailRow label="Due Date" value="2025-11-05" />
  <DetailRow label="Vendor" value="ABC Supply Co., Ltd." />
  <DetailRow label="Amount" value={<AmountDisplay amount={1000} />} />
  <DetailRow label="Tax" value={<AmountDisplay amount={70} />} />
  <DetailRow label="Total" value={<AmountDisplay amount={1070} />} bold />
  <DetailRow label="Status" value={<StatusBadge status="Approved" />} />
</DetailCard>
```

---

### 4.5 Timeline

**Purpose**: Display chronological events

**Example:**
```tsx
<Timeline>
  <TimelineItem
    date="2025-10-06 10:30"
    icon={<Create />}
    title="Invoice Created"
    description="Created by John Doe"
  />
  <TimelineItem
    date="2025-10-07 14:15"
    icon={<Send />}
    title="Submitted for Approval"
    description="Submitted to Finance Manager"
  />
  <TimelineItem
    date="2025-10-08 09:20"
    icon={<Check />}
    title="Approved"
    description="Approved by Jane Smith"
    status="success"
  />
  <TimelineItem
    date="2025-10-08 10:00"
    icon={<AccountBalance />}
    title="Posted to GL"
    description="JV Number: JV-2025-001"
    status="success"
  />
</Timeline>
```

---

## 5. Form Components

### 5.1 TextField

**Purpose**: Single-line text input

**Props:**
```typescript
interface TextFieldProps {
  label: string;
  name: string;
  value: string;
  onChange: (value: string) => void;
  error?: string;
  required?: boolean;
  disabled?: boolean;
  placeholder?: string;
  maxLength?: number;
}
```

**Example:**
```tsx
<TextField
  label="Invoice Number"
  name="invoiceNumber"
  value={formData.invoiceNumber}
  onChange={handleChange}
  error={errors.invoiceNumber}
  required
  placeholder="INV-YYYY-NNNN"
  maxLength={50}
/>
```

---

### 5.2 Select

**Purpose**: Dropdown selection

**Example:**
```tsx
<Select
  label="Vendor"
  name="vendorCode"
  value={formData.vendorCode}
  onChange={handleChange}
  options={vendors.map(v => ({ value: v.vnCode, label: v.vnName }))}
  required
  searchable
  error={errors.vendorCode}
/>
```

---

### 5.3 DatePicker

**Purpose**: Date selection with calendar

**Example:**
```tsx
<DatePicker
  label="Invoice Date"
  name="invoiceDate"
  value={formData.invoiceDate}
  onChange={handleDateChange}
  maxDate={new Date()}  // Cannot be future date
  required
  error={errors.invoiceDate}
/>
```

---

### 5.4 AmountInput

**Purpose**: Formatted currency input

**Example:**
```tsx
<AmountInput
  label="Amount"
  name="amount"
  value={formData.amount}
  onChange={handleAmountChange}
  currency="THB"
  min={0.01}
  required
  error={errors.amount}
/>
```

---

### 5.5 AutocompleteSelect

**Purpose**: Searchable dropdown with async data loading

**Example:**
```tsx
<AutocompleteSelect
  label="GL Account"
  name="accountCode"
  value={formData.accountCode}
  onChange={handleAccountChange}
  loadOptions={async (query) => {
    const response = await api.get('/api/account-code/search', { params: { q: query } });
    return response.data.map(acc => ({
      value: acc.accCode,
      label: `${acc.accCode} - ${acc.accDesc}`
    }));
  }}
  required
  error={errors.accountCode}
/>
```

---

### 5.6 FileUpload

**Purpose**: File upload with drag-and-drop

**Example:**
```tsx
<FileUpload
  label="Attachments"
  accept=".pdf,.jpg,.png,.xlsx"
  maxSize={5 * 1024 * 1024}  // 5MB
  multiple
  onChange={handleFileUpload}
  files={formData.attachments}
/>
```

---

## 6. Navigation Components

### 6.1 Tabs

**Purpose**: Organize content into sections

**Example:**
```tsx
<Tabs value={activeTab} onChange={handleTabChange}>
  <Tab label="Invoice Details" value="details" />
  <Tab label="Line Items" value="lines" />
  <Tab label="Payment History" value="payments" />
  <Tab label="Attachments" value="attachments" />
  <Tab label="Audit Log" value="audit" />
</Tabs>

<TabPanel value={activeTab} index="details">
  <InvoiceDetailsForm />
</TabPanel>
<TabPanel value={activeTab} index="lines">
  <InvoiceLineItemsTable />
</TabPanel>
```

---

### 6.2 Stepper

**Purpose**: Multi-step workflow indicator

**Example:**
```tsx
<Stepper activeStep={currentStep}>
  <Step label="Invoice Details" completed={currentStep > 0} />
  <Step label="Line Items" completed={currentStep > 1} />
  <Step label="Review" completed={currentStep > 2} />
  <Step label="Submit" completed={currentStep > 3} />
</Stepper>
```

---

## 7. Feedback Components

### 7.1 Alert

**Purpose**: Display contextual feedback messages

**Variants:**
```tsx
<Alert severity="success">Invoice created successfully!</Alert>
<Alert severity="info">Invoice requires approval before posting.</Alert>
<Alert severity="warning">This invoice is past due by 15 days.</Alert>
<Alert severity="error">Failed to save invoice. Please try again.</Alert>
```

---

### 7.2 Snackbar

**Purpose**: Temporary notification

**Example:**
```tsx
<Snackbar
  open={showSnackbar}
  message="Invoice saved successfully"
  severity="success"
  autoHideDuration={3000}
  onClose={handleClose}
  action={<Button onClick={handleUndo}>Undo</Button>}
/>
```

---

### 7.3 ConfirmDialog

**Purpose**: Confirmation prompt for destructive actions

**Example:**
```tsx
<ConfirmDialog
  open={showConfirm}
  title="Delete Invoice"
  message="Are you sure you want to delete invoice INV-2025-001? This action cannot be undone."
  confirmText="Delete"
  cancelText="Cancel"
  onConfirm={handleDelete}
  onCancel={() => setShowConfirm(false)}
  severity="error"
/>
```

---

### 7.4 LoadingOverlay

**Purpose**: Indicate loading state

**Example:**
```tsx
<LoadingOverlay open={loading} message="Saving invoice..." />
```

---

### 7.5 ProgressBar

**Purpose**: Show progress for long-running operations

**Example:**
```tsx
<ProgressBar
  value={progress}
  label="Processing invoices..."
  showPercentage
/>
```

---

## 8. Business Components

### 8.1 ApInvoiceForm

**Purpose**: Create/edit AP invoices

**Sections:**
1. **Header Section**
   - Invoice Number (auto-generated)
   - Invoice Date
   - Due Date (calculated based on payment terms)
   - Vendor Selector
   - Description

2. **Amount Section**
   - Amount (before tax)
   - Tax Amount (calculated)
   - WHT Amount (optional)
   - Total Amount (calculated)

3. **Line Items Section**
   - Editable data grid
   - Columns: Line #, Description, Account Code, Dept, Amount
   - Add/Remove lines
   - Line totals validation

4. **Actions**
   - Save Draft
   - Submit for Approval
   - Cancel

**Example:**
```tsx
<ApInvoiceForm
  mode="create"
  initialData={null}
  onSave={handleSave}
  onCancel={handleCancel}
/>
```

---

### 8.2 PaymentApplicationForm

**Purpose**: Apply payments to invoices

**Features:**
- Select unpaid invoices
- Allocate payment amount across invoices
- FIFO application suggestion
- Partial payment support

---

### 8.3 GlJournalVoucherForm

**Purpose**: Create GL journal entries

**Features:**
- Add DR/CR lines
- Auto-balance validation (DR = CR)
- Account code lookup
- Department allocation
- Period validation

---

## 9. Component Design Patterns

### Pattern 1: Container/Presenter

```tsx
// Container (Smart Component)
const ApInvoiceListContainer: React.FC = () => {
  const [invoices, setInvoices] = useState<ViewApInvoice[]>([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    loadInvoices();
  }, []);

  const loadInvoices = async () => {
    setLoading(true);
    const response = await api.get('/api/apInvoice');
    setInvoices(response.data);
    setLoading(false);
  };

  return (
    <ApInvoiceListPresenter
      invoices={invoices}
      loading={loading}
      onRefresh={loadInvoices}
    />
  );
};

// Presenter (Dumb Component)
interface ApInvoiceListPresenterProps {
  invoices: ViewApInvoice[];
  loading: boolean;
  onRefresh: () => void;
}

const ApInvoiceListPresenter: React.FC<ApInvoiceListPresenterProps> = ({
  invoices,
  loading,
  onRefresh
}) => {
  return (
    <div>
      <Button onClick={onRefresh}>Refresh</Button>
      {loading ? <LoadingOverlay /> : <DataTable data={invoices} />}
    </div>
  );
};
```

### Pattern 2: Custom Hooks

```tsx
// useApInvoice.ts
export const useApInvoice = (invhSeq?: number) => {
  const [invoice, setInvoice] = useState<ViewApInvoice | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (invhSeq) {
      loadInvoice(invhSeq);
    }
  }, [invhSeq]);

  const loadInvoice = async (id: number) => {
    setLoading(true);
    try {
      const response = await api.get(`/api/apInvoice/${id}`);
      setInvoice(response.data);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const updateInvoice = async (data: ParamApInvoice) => {
    const response = await api.put(`/api/apInvoice/${invhSeq}`, data);
    setInvoice(response.data);
  };

  return { invoice, loading, error, updateInvoice };
};

// Usage
const ApInvoiceDetail = ({ invhSeq }: { invhSeq: number }) => {
  const { invoice, loading, error, updateInvoice } = useApInvoice(invhSeq);

  if (loading) return <LoadingOverlay />;
  if (error) return <Alert severity="error">{error}</Alert>;

  return <DetailCard data={invoice} onSave={updateInvoice} />;
};
```

---

## Summary

Carmen.NET UI Component Inventory:

**✅ Documented:**
- 40+ reusable UI components
- 8 component categories
- Design system guidelines
- Component design patterns

**📦 Component Categories:**
1. Layout Components (5)
2. Data Display Components (5)
3. Form Components (6)
4. Navigation Components (2)
5. Feedback Components (5)
6. Business Components (3)

**🎨 Design System:**
- Color palette (primary, secondary, status)
- Typography scale
- Spacing system (4px grid)
- Responsive breakpoints

**🔧 Recommended Stack:**
- React 18+ with TypeScript
- Material-UI or Ant Design
- TanStack Table for data grids
- React Hook Form for forms
- SignalR for real-time updates

**Next Steps:**
- Review [Screen Flow Diagrams](screen-flow-diagrams.md) for user journeys
- Study [Functional Requirements](../requirements/functional-requirements.md) for component behavior
- Reference [API Documentation](../api/api-reference.md) for data contracts

---

**Document Status:** ✅ Complete
**For Support:** Contact UI/UX team or frontend development team
