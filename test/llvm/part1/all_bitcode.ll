; ModuleID = 'all_bitcode'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

define double* @matvec(double** %A, double* %B, double* %C, i32 %n) nounwind uwtable {
  %1 = alloca double*, align 8
  %2 = alloca double**, align 8
  %3 = alloca double*, align 8
  %4 = alloca double*, align 8
  %5 = alloca i32, align 4
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  store double** %A, double*** %2, align 8
  store double* %B, double** %3, align 8
  store double* %C, double** %4, align 8
  store i32 %n, i32* %5, align 4
  store i32 0, i32* %i, align 4
  br label %6

; <label>:6                                       ; preds = %50, %0
  %7 = load i32* %i, align 4
  %8 = load i32* %5, align 4
  %9 = icmp slt i32 %7, %8
  br i1 %9, label %10, label %53

; <label>:10                                      ; preds = %6
  %11 = load i32* %i, align 4
  %12 = sext i32 %11 to i64
  %13 = load double** %4, align 8
  %14 = getelementptr inbounds double* %13, i64 %12
  store double 0.000000e+00, double* %14
  store i32 0, i32* %j, align 4
  br label %15

; <label>:15                                      ; preds = %45, %10
  %16 = load i32* %j, align 4
  %17 = load i32* %5, align 4
  %18 = icmp slt i32 %16, %17
  br i1 %18, label %19, label %48

; <label>:19                                      ; preds = %15
  %20 = load i32* %i, align 4
  %21 = sext i32 %20 to i64
  %22 = load double** %4, align 8
  %23 = getelementptr inbounds double* %22, i64 %21
  %24 = load double* %23
  %25 = load i32* %j, align 4
  %26 = sext i32 %25 to i64
  %27 = load i32* %i, align 4
  %28 = sext i32 %27 to i64
  %29 = load double*** %2, align 8
  %30 = getelementptr inbounds double** %29, i64 %28
  %31 = load double** %30
  %32 = getelementptr inbounds double* %31, i64 %26
  %33 = load double* %32
  %34 = load i32* %j, align 4
  %35 = sext i32 %34 to i64
  %36 = load double** %3, align 8
  %37 = getelementptr inbounds double* %36, i64 %35
  %38 = load double* %37
  %39 = fmul double %33, %38
  %40 = fadd double %24, %39
  %41 = load i32* %i, align 4
  %42 = sext i32 %41 to i64
  %43 = load double** %4, align 8
  %44 = getelementptr inbounds double* %43, i64 %42
  store double %40, double* %44
  br label %45

; <label>:45                                      ; preds = %19
  %46 = load i32* %j, align 4
  %47 = add nsw i32 %46, 1
  store i32 %47, i32* %j, align 4
  br label %15

; <label>:48                                      ; preds = %15
  %49 = load double** %4, align 8
  store double* %49, double** %1
  br label %53
                                                  ; No predecessors!
  %51 = load i32* %i, align 4
  %52 = add nsw i32 %51, 1
  store i32 %52, i32* %i, align 4
  br label %6

; <label>:53                                      ; preds = %48, %6
  %54 = load double** %1
  ret double* %54
}

define i32 @main(i32 %argc, i8** %argv) nounwind uwtable {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  %3 = alloca i8**, align 8
  %A = alloca [10 x [10 x double]], align 16
  %B = alloca [10 x double], align 16
  %C = alloca [10 x double], align 16
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  %n = alloca i32, align 4
  %p = alloca double*, align 8
  %a = alloca double**, align 8
  %b = alloca double*, align 8
  store i32 0, i32* %1
  store i32 %argc, i32* %2, align 4
  store i8** %argv, i8*** %3, align 8
  %4 = getelementptr inbounds [10 x double]* %C, i32 0, i32 0
  store double* %4, double** %p, align 8
  %5 = getelementptr inbounds [10 x [10 x double]]* %A, i32 0, i64 0
  %6 = getelementptr inbounds [10 x double]* %5, i32 0, i64 0
  %7 = load double* %6, align 8
  %8 = load double*** %a, align 8
  %9 = load double** %8
  store double %7, double* %9
  %10 = getelementptr inbounds [10 x double]* %B, i32 0, i64 0
  %11 = load double* %10, align 8
  %12 = load double** %b, align 8
  store double %11, double* %12
  store i32 10, i32* %n, align 4
  store i32 0, i32* %i, align 4
  br label %13

; <label>:13                                      ; preds = %37, %0
  %14 = load i32* %i, align 4
  %15 = icmp slt i32 %14, 10
  br i1 %15, label %16, label %40

; <label>:16                                      ; preds = %13
  store i32 0, i32* %j, align 4
  br label %17

; <label>:17                                      ; preds = %33, %16
  %18 = load i32* %j, align 4
  %19 = icmp slt i32 %18, 10
  br i1 %19, label %20, label %36

; <label>:20                                      ; preds = %17
  %21 = load i32* %i, align 4
  %22 = load i32* %j, align 4
  %23 = mul nsw i32 %22, 2
  %24 = mul nsw i32 %23, 3
  %25 = add nsw i32 %21, %24
  %26 = sitofp i32 %25 to double
  %27 = load i32* %j, align 4
  %28 = sext i32 %27 to i64
  %29 = load i32* %i, align 4
  %30 = sext i32 %29 to i64
  %31 = getelementptr inbounds [10 x [10 x double]]* %A, i32 0, i64 %30
  %32 = getelementptr inbounds [10 x double]* %31, i32 0, i64 %28
  store double %26, double* %32, align 8
  br label %33

; <label>:33                                      ; preds = %20
  %34 = load i32* %j, align 4
  %35 = add nsw i32 %34, 1
  store i32 %35, i32* %j, align 4
  br label %17

; <label>:36                                      ; preds = %17
  br label %37

; <label>:37                                      ; preds = %36
  %38 = load i32* %i, align 4
  %39 = add nsw i32 %38, 1
  store i32 %39, i32* %i, align 4
  br label %13

; <label>:40                                      ; preds = %13
  store i32 0, i32* %i, align 4
  br label %41

; <label>:41                                      ; preds = %55, %40
  %42 = load i32* %i, align 4
  %43 = icmp slt i32 %42, 10
  br i1 %43, label %44, label %58

; <label>:44                                      ; preds = %41
  %45 = load i32* %i, align 4
  %46 = mul nsw i32 %45, 10
  %47 = load i32* %i, align 4
  %48 = mul nsw i32 %47, 2
  %49 = sub nsw i32 %46, %48
  %50 = add nsw i32 %49, 3
  %51 = sitofp i32 %50 to double
  %52 = load i32* %i, align 4
  %53 = sext i32 %52 to i64
  %54 = getelementptr inbounds [10 x double]* %B, i32 0, i64 %53
  store double %51, double* %54, align 8
  br label %55

; <label>:55                                      ; preds = %44
  %56 = load i32* %i, align 4
  %57 = add nsw i32 %56, 1
  store i32 %57, i32* %i, align 4
  br label %41

; <label>:58                                      ; preds = %41
  %59 = load double*** %a, align 8
  %60 = load double** %b, align 8
  %61 = getelementptr inbounds [10 x double]* %C, i32 0, i32 0
  %62 = load i32* %n, align 4
  %63 = call double* @matvec(double** %59, double* %60, double* %61, i32 %62)
  store double* %63, double** %p, align 8
  ret i32 0
}
