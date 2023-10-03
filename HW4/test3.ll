; === prologue ====
declare dso_local i32 @printf(i8*, ...)

@str0= private unnamed_addr constant [7 x i8] c"%d\0A%d\0A\00"
define dso_local i32 @main()
{
%t0 = alloca i32, align 4
%t1 = alloca i32, align 4
%t2 = alloca i32, align 4
%t3 = alloca i32, align 4
store i32 10, i32* %t3
store i32 1, i32* %t2
store i32 2, i32* %t1
store i32 0, i32* %t0
br label %L0
L0:
%t4=load i32, i32* %t3
%cond0 = icmp sge i32 %t4, 0
br i1 %cond0, label %L1, label %L2
L1:
%t5=load i32, i32* %t3
%cond1 = icmp sge i32 %t5, 5
br i1 %cond1, label %L3, label %L4
L3:
%t6=load i32, i32* %t3
%t7=load i32, i32* %t2
%t8 = sub nsw i32 %t6, %t7
store i32 %t8, i32* %t3
%t9=load i32, i32* %t0
%t10 = add nsw i32 %t9, 1
store i32 %t10, i32* %t0
br label %Lend0
L4:
%t11=load i32, i32* %t3
%t12=load i32, i32* %t1
%t13 = sub nsw i32 %t11, %t12
store i32 %t13, i32* %t3
%t14=load i32, i32* %t0
%t15 = add nsw i32 %t14, 1
store i32 %t15, i32* %t0
br label %Lend0
Lend0:
br label %L0
L2:
%t16=load i32, i32* %t3
%t17=load i32, i32* %t0
%t18= call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([7 x i8], [7 x i8]* @str0, i64 0, i64 0), i32 %t16, i32 %t17)

; === epilogue ===
ret i32 0
}
