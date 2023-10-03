; === prologue ====
declare dso_local i32 @printf(i8*, ...)

@str0= private unnamed_addr constant [10 x i8] c"%d\0A%d\0A%d\0A\00"
define dso_local i32 @main()
{
%t0 = alloca i32, align 4
%t1 = alloca i32, align 4
%t2 = alloca i32, align 4
store i32 0, i32* %t1
store i32 0, i32* %t0
store i32 0, i32* %t2
br label %L0
L0:
%t3=load i32, i32* %t2
%cond0 = icmp slt i32 %t3, 10
br i1 %cond0, label %L1, label %L2
br label %L3
L3:
%t4=load i32, i32* %t2
%t5 = add nsw i32 %t4, 1
store i32 %t5, i32* %t2
br label %L0
L1:
%t6=load i32, i32* %t2
%cond1 = icmp slt i32 %t6, 5
br i1 %cond1, label %L4, label %L5
L4:
%t7=load i32, i32* %t1
%cond2 = icmp eq i32 %t7, 0
br i1 %cond2, label %L6, label %L7
L6:
store i32 100, i32* %t1
br label %Lend0
L7:
%t8=load i32, i32* %t1
%t9 = add nsw i32 %t8, 1
store i32 %t9, i32* %t1
br label %Lend0
Lend0:
br label %Lend1
L5:
%t10=load i32, i32* %t0
%t11 = add nsw i32 %t10, 1
store i32 %t11, i32* %t0
br label %Lend1
Lend1:
br label %L3
L2:
%t12=load i32, i32* %t2
%t13=load i32, i32* %t1
%t14=load i32, i32* %t0
%t15= call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([10 x i8], [10 x i8]* @str0, i64 0, i64 0), i32 %t12, i32 %t13, i32 %t14)

; === epilogue ===
ret i32 0
}
