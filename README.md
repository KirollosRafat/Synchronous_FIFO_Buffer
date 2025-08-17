# Synchronous FIFO Design and Verification  

## 📌 Overview  
This project implements a **Synchronous FIFO (First-In-First-Out) buffer** in Verilog, along with a **SystemVerilog testbench** and **assertions-based verification**.  

A **Synchronous FIFO** is a special type of FIFO where both **read** and **write** operations are controlled by the **same clock domain**. It is commonly used in digital systems for buffering data between producer and consumer processes running at the same clock frequency.  

---

## 📊 Architecture  

![Synchronous FIFO](synchronous-fifo.gif)  

---

## 📂 Repository Structure  

```
├── Sync_FIFO.v        # Verilog implementation of synchronous FIFO
├── Sync_FIFO_tb.sv    # SystemVerilog testbench with stimulus and coverage
├── Assertions.sv      # SystemVerilog assertions for design verification
├── synchronous-fifo.gif # FIFO architecture diagram
└── README.md          # Project documentation
```

---

## ⚙️ Module Descriptions  

### 🔹 `Sync_FIFO.v`  
- Implements a **synchronous FIFO** with configurable depth and width.  
- Provides **write** and **read** operations controlled by enable signals.  
- Handles **full** and **empty** conditions to prevent overflow and underflow.  

### 🔹 `Sync_FIFO_tb.sv`  
- A SystemVerilog **testbench** for simulating the FIFO.  
- Includes:  
  - **Stimulus generation** for write/read sequences.  
  - **Functional coverage** using **covergroups and constraints**, ensuring that all important scenarios (e.g., full, empty, corner cases) are tested.  
  - **Output checks** to validate FIFO correctness.  

### 🔹 `Assertions.sv`  
- Contains **SystemVerilog Assertions (SVA)**.  
- Ensures FIFO protocol compliance and detects design bugs such as:  
  - Writing when FIFO is full  
  - Reading when FIFO is empty  
  - Data ordering violations  

---

## ▶️ How to Run (QuestaSim/ModelSim)  

```tcl
vlog Sync_FIFO.v Sync_FIFO_tb.sv Assertions.sv
vsim work.Sync_FIFO_tb
run -all
```

---

## ✅ Verification  
- **Assertions** check design properties dynamically during simulation.  
- **Functional coverage** ensures that all FIFO conditions (full, empty, boundary cases) are exercised.  
- The **testbench** validates:  
  - FIFO push and pop operations  
  - Empty/full flag correctness  
  - Proper First-In-First-Out data ordering  
