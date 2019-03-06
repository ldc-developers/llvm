; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse4.1 | FileCheck %s --check-prefix=SSE
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx2 | FileCheck %s --check-prefix=AVX

declare {i32, i1} @llvm.ssub.with.overflow.i32(i32, i32) nounwind readnone
declare {i32, i1} @llvm.usub.with.overflow.i32(i32, i32) nounwind readnone

declare {<4 x i32>, <4 x i1>} @llvm.ssub.with.overflow.v4i32(<4 x i32>, <4 x i32>) nounwind readnone
declare {<4 x i32>, <4 x i1>} @llvm.usub.with.overflow.v4i32(<4 x i32>, <4 x i32>) nounwind readnone

; fold (ssub x, 0) -> x
define i32 @combine_ssub_zero(i32 %a0, i32 %a1) {
; SSE-LABEL: combine_ssub_zero:
; SSE:       # %bb.0:
; SSE-NEXT:    movl %edi, %eax
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_ssub_zero:
; AVX:       # %bb.0:
; AVX-NEXT:    movl %edi, %eax
; AVX-NEXT:    retq
  %1 = call {i32, i1} @llvm.ssub.with.overflow.i32(i32 %a0, i32 zeroinitializer)
  %2 = extractvalue {i32, i1} %1, 0
  %3 = extractvalue {i32, i1} %1, 1
  %4 = select i1 %3, i32 %a1, i32 %2
  ret i32 %4
}

define <4 x i32> @combine_vec_ssub_zero(<4 x i32> %a0, <4 x i32> %a1) {
; SSE-LABEL: combine_vec_ssub_zero:
; SSE:       # %bb.0:
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_vec_ssub_zero:
; AVX:       # %bb.0:
; AVX-NEXT:    retq
  %1 = call {<4 x i32>, <4 x i1>} @llvm.ssub.with.overflow.v4i32(<4 x i32> %a0, <4 x i32> zeroinitializer)
  %2 = extractvalue {<4 x i32>, <4 x i1>} %1, 0
  %3 = extractvalue {<4 x i32>, <4 x i1>} %1, 1
  %4 = select <4 x i1> %3, <4 x i32> %a1, <4 x i32> %2
  ret <4 x i32> %4
}

; fold (usub x, 0) -> x
define i32 @combine_usub_zero(i32 %a0, i32 %a1) {
; SSE-LABEL: combine_usub_zero:
; SSE:       # %bb.0:
; SSE-NEXT:    movl %edi, %eax
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_usub_zero:
; AVX:       # %bb.0:
; AVX-NEXT:    movl %edi, %eax
; AVX-NEXT:    retq
  %1 = call {i32, i1} @llvm.usub.with.overflow.i32(i32 %a0, i32 zeroinitializer)
  %2 = extractvalue {i32, i1} %1, 0
  %3 = extractvalue {i32, i1} %1, 1
  %4 = select i1 %3, i32 %a1, i32 %2
  ret i32 %4
}

define <4 x i32> @combine_vec_usub_zero(<4 x i32> %a0, <4 x i32> %a1) {
; SSE-LABEL: combine_vec_usub_zero:
; SSE:       # %bb.0:
; SSE-NEXT:    movdqa %xmm0, %xmm2
; SSE-NEXT:    pminud %xmm0, %xmm0
; SSE-NEXT:    pcmpeqd %xmm2, %xmm0
; SSE-NEXT:    blendvps %xmm0, %xmm2, %xmm1
; SSE-NEXT:    movaps %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_vec_usub_zero:
; AVX:       # %bb.0:
; AVX-NEXT:    vpminud %xmm0, %xmm0, %xmm2
; AVX-NEXT:    vpcmpeqd %xmm2, %xmm0, %xmm2
; AVX-NEXT:    vblendvps %xmm2, %xmm0, %xmm1, %xmm0
; AVX-NEXT:    retq
  %1 = call {<4 x i32>, <4 x i1>} @llvm.usub.with.overflow.v4i32(<4 x i32> %a0, <4 x i32> zeroinitializer)
  %2 = extractvalue {<4 x i32>, <4 x i1>} %1, 0
  %3 = extractvalue {<4 x i32>, <4 x i1>} %1, 1
  %4 = select <4 x i1> %3, <4 x i32> %a1, <4 x i32> %2
  ret <4 x i32> %4
}

; fold (ssub x, x) -> 0
define i32 @combine_ssub_self(i32 %a0, i32 %a1) {
; SSE-LABEL: combine_ssub_self:
; SSE:       # %bb.0:
; SSE-NEXT:    xorl %eax, %eax
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_ssub_self:
; AVX:       # %bb.0:
; AVX-NEXT:    xorl %eax, %eax
; AVX-NEXT:    retq
  %1 = call {i32, i1} @llvm.ssub.with.overflow.i32(i32 %a0, i32 %a0)
  %2 = extractvalue {i32, i1} %1, 0
  %3 = extractvalue {i32, i1} %1, 1
  %4 = select i1 %3, i32 %a1, i32 %2
  ret i32 %4
}

define <4 x i32> @combine_vec_ssub_self(<4 x i32> %a0, <4 x i32> %a1) {
; SSE-LABEL: combine_vec_ssub_self:
; SSE:       # %bb.0:
; SSE-NEXT:    xorps %xmm0, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_vec_ssub_self:
; AVX:       # %bb.0:
; AVX-NEXT:    vxorps %xmm0, %xmm0, %xmm0
; AVX-NEXT:    retq
  %1 = call {<4 x i32>, <4 x i1>} @llvm.ssub.with.overflow.v4i32(<4 x i32> %a0, <4 x i32> %a0)
  %2 = extractvalue {<4 x i32>, <4 x i1>} %1, 0
  %3 = extractvalue {<4 x i32>, <4 x i1>} %1, 1
  %4 = select <4 x i1> %3, <4 x i32> %a1, <4 x i32> %2
  ret <4 x i32> %4
}

; fold (usub x, x) -> x
define i32 @combine_usub_self(i32 %a0, i32 %a1) {
; SSE-LABEL: combine_usub_self:
; SSE:       # %bb.0:
; SSE-NEXT:    xorl %eax, %eax
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_usub_self:
; AVX:       # %bb.0:
; AVX-NEXT:    xorl %eax, %eax
; AVX-NEXT:    retq
  %1 = call {i32, i1} @llvm.usub.with.overflow.i32(i32 %a0, i32 %a0)
  %2 = extractvalue {i32, i1} %1, 0
  %3 = extractvalue {i32, i1} %1, 1
  %4 = select i1 %3, i32 %a1, i32 %2
  ret i32 %4
}

define <4 x i32> @combine_vec_usub_self(<4 x i32> %a0, <4 x i32> %a1) {
; SSE-LABEL: combine_vec_usub_self:
; SSE:       # %bb.0:
; SSE-NEXT:    movdqa %xmm0, %xmm2
; SSE-NEXT:    psubd %xmm0, %xmm2
; SSE-NEXT:    pminud %xmm2, %xmm0
; SSE-NEXT:    pcmpeqd %xmm2, %xmm0
; SSE-NEXT:    blendvps %xmm0, %xmm2, %xmm1
; SSE-NEXT:    movaps %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_vec_usub_self:
; AVX:       # %bb.0:
; AVX-NEXT:    vpsubd %xmm0, %xmm0, %xmm2
; AVX-NEXT:    vpminud %xmm0, %xmm2, %xmm0
; AVX-NEXT:    vpcmpeqd %xmm0, %xmm2, %xmm0
; AVX-NEXT:    vblendvps %xmm0, %xmm2, %xmm1, %xmm0
; AVX-NEXT:    retq
  %1 = call {<4 x i32>, <4 x i1>} @llvm.usub.with.overflow.v4i32(<4 x i32> %a0, <4 x i32> %a0)
  %2 = extractvalue {<4 x i32>, <4 x i1>} %1, 0
  %3 = extractvalue {<4 x i32>, <4 x i1>} %1, 1
  %4 = select <4 x i1> %3, <4 x i32> %a1, <4 x i32> %2
  ret <4 x i32> %4
}

; fold (usub -1, x) -> (xor x, -1) + no borrow
define i32 @combine_usub_negone(i32 %a0, i32 %a1) {
; SSE-LABEL: combine_usub_negone:
; SSE:       # %bb.0:
; SSE-NEXT:    movl %edi, %eax
; SSE-NEXT:    notl %eax
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_usub_negone:
; AVX:       # %bb.0:
; AVX-NEXT:    movl %edi, %eax
; AVX-NEXT:    notl %eax
; AVX-NEXT:    retq
  %1 = call {i32, i1} @llvm.usub.with.overflow.i32(i32 -1, i32 %a0)
  %2 = extractvalue {i32, i1} %1, 0
  %3 = extractvalue {i32, i1} %1, 1
  %4 = select i1 %3, i32 %a1, i32 %2
  ret i32 %4
}

define <4 x i32> @combine_vec_usub_negone(<4 x i32> %a0, <4 x i32> %a1) {
; SSE-LABEL: combine_vec_usub_negone:
; SSE:       # %bb.0:
; SSE-NEXT:    movdqa %xmm0, %xmm2
; SSE-NEXT:    pcmpeqd %xmm0, %xmm0
; SSE-NEXT:    pxor %xmm0, %xmm2
; SSE-NEXT:    pminud %xmm2, %xmm0
; SSE-NEXT:    pcmpeqd %xmm2, %xmm0
; SSE-NEXT:    blendvps %xmm0, %xmm2, %xmm1
; SSE-NEXT:    movaps %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_vec_usub_negone:
; AVX:       # %bb.0:
; AVX-NEXT:    vpcmpeqd %xmm2, %xmm2, %xmm2
; AVX-NEXT:    vpxor %xmm2, %xmm0, %xmm0
; AVX-NEXT:    vpminud %xmm2, %xmm0, %xmm2
; AVX-NEXT:    vpcmpeqd %xmm2, %xmm0, %xmm2
; AVX-NEXT:    vblendvps %xmm2, %xmm0, %xmm1, %xmm0
; AVX-NEXT:    retq
  %1 = call {<4 x i32>, <4 x i1>} @llvm.usub.with.overflow.v4i32(<4 x i32> <i32 -1, i32 -1, i32 -1, i32 -1>, <4 x i32> %a0)
  %2 = extractvalue {<4 x i32>, <4 x i1>} %1, 0
  %3 = extractvalue {<4 x i32>, <4 x i1>} %1, 1
  %4 = select <4 x i1> %3, <4 x i32> %a1, <4 x i32> %2
  ret <4 x i32> %4
}
