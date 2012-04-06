define double* @matvec(double** %A, double* %B, double* %C, i32 %n) nounwind uwtable {
  %1 = alloca double**, align 8
  %2 = alloca double*, align 8
  %3 = alloca double*, align 8
  %4 = alloca i32, align 4
  %i = alloca i32, align 4
  %j = alloca i32, align 4
  store double** %A, double*** %1, align 8
  store double* %B, double** %2, align 8
  store double* %C, double** %3, align 8
  store i32 %n, i32* %4, align 4
  store i32 0, i32* %i, align 4
  br label %5

; <label>:5                                       ; preds = %48, %0
  %6 = load i32* %i, align 4
  %7 = load i32* %4, align 4
  %8 = icmp slt i32 %6, %7
  br i1 %8, label %9, label %51

; <label>:9                                       ; preds = %5
  %10 = load i32* %i, align 4
  %11 = sext i32 %10 to i64
  %12 = load double** %3, align 8
  %13 = getelementptr inbounds double* %12, i64 %11
  store double 0.000000e+00, double* %13
  store i32 0, i32* %j, align 4
  br label %14

; <label>:14                                      ; preds = %44, %9
  %15 = load i32* %j, align 4
  %16 = load i32* %4, align 4
  %17 = icmp slt i32 %15, %16
  br i1 %17, label %18, label %47

; <label>:18                                      ; preds = %14
  %19 = load i32* %i, align 4
  %20 = sext i32 %19 to i64
  %21 = load double** %3, align 8
  %22 = getelementptr inbounds double* %21, i64 %20
  %23 = load double* %22
  %24 = load i32* %j, align 4
  %25 = sext i32 %24 to i64
  %26 = load i32* %i, align 4
  %27 = sext i32 %26 to i64
  %28 = load double*** %1, align 8
  %29 = getelementptr inbounds double** %28, i64 %27
  %30 = load double** %29
  %31 = getelementptr inbounds double* %30, i64 %25
  %32 = load double* %31
  %33 = load i32* %j, align 4
  %34 = sext i32 %33 to i64
  %35 = load double** %2, align 8
  %36 = getelementptr inbounds double* %35, i64 %34
  %37 = load double* %36
  %38 = fmul double %32, %37
  %39 = fadd double %23, %38
  %40 = load i32* %i, align 4
  %41 = sext i32 %40 to i64
  %42 = load double** %3, align 8
  %43 = getelementptr inbounds double* %42, i64 %41
  store double %39, double* %43
  br label %44

; <label>:44                                      ; preds = %18
  %45 = load i32* %j, align 4
  %46 = add nsw i32 %45, 1
  store i32 %46, i32* %j, align 4
  br label %14

; <label>:47                                      ; preds = %14
  br label %48

; <label>:48                                      ; preds = %47
  %49 = load i32* %i, align 4
  %50 = add nsw i32 %49, 1
  store i32 %50, i32* %i, align 4
  br label %5

; <label>:51                                      ; preds = %5
  %52 = load double** %3, align 8
  ret double* %52
}