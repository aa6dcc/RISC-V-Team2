// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef VERILATED_VDUT__SYMS_H_
#define VERILATED_VDUT__SYMS_H_  // guard

#include "verilated.h"

// INCLUDE MODEL CLASS

#include "Vdut.h"

// INCLUDE MODULE CLASSES
#include "Vdut___024root.h"

// SYMS CLASS (contains all model state)
class alignas(VL_CACHE_LINE_BYTES)Vdut__Syms final : public VerilatedSyms {
  public:
    // INTERNAL STATE
    Vdut* const __Vm_modelp;
    bool __Vm_activity = false;  ///< Used by trace routines to determine change occurred
    uint32_t __Vm_baseCode = 0;  ///< Used by trace routines when tracing multiple models
    VlDeleter __Vm_deleter;
    bool __Vm_didInit = false;

    // MODULE INSTANCE STATE
    Vdut___024root                 TOP;

    // COVERAGE
<<<<<<< HEAD
    uint32_t __Vcoverage[545];
=======
<<<<<<< HEAD
    uint32_t __Vcoverage[325];
=======
    uint32_t __Vcoverage[293];
>>>>>>> eb3bdf312f85bad8b93cf3d4854b3dab6203a693
>>>>>>> 6f639c6742bb658f8884e38c3ff071e0ea8e22c5

    // CONSTRUCTORS
    Vdut__Syms(VerilatedContext* contextp, const char* namep, Vdut* modelp);
    ~Vdut__Syms();

    // METHODS
    const char* name() { return TOP.name(); }
};

#endif  // guard
