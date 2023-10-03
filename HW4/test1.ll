; === prologue ====
declare dso_local i32 @printf(i8*, ...)

@str0= private unnamed_addr constant [4 x i8] c"%d\0A\00"
@str1= private unnamed_addr constant [4 x i8] c"%d\0A\00"
@str2= private unnamed_addr constant [13 x i8] c"Hello World\0A\00"
@str3= private unnamed_addr constant [4 x i8] c"%d\0A\00"
@str4= private unnamed_addr constant [7 x i8] c"Error\0A\00"
define dso_local i32 @main()
{
%t0 = alloca i32, align 4
%t1 = alloca i32, align 4
store i32 1, i32* %t1
%t2=load i32, i32* %t1
%t3 = add nsw i32 %t2, 2
store i32 %t3, i32* %t0
%t4=load i32, i32* %t1
%cond0 = icmp eq i32 %t4, 1
br i1 %cond0, label %L0, label %L1
L0:
%t5=load i32, i32* %t0
%t6= call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @str0, i64 0, i64 0), i32 %t5)
%t7=load i32, i32* %t0
%cond1 = icmp slt i32 %t7, 3
br i1 %cond1, label %L2, label %L3
L2:
%t8=load i32, i32* %t0
%t9= call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @str1, i64 0, i64 0), i32 %t8)
br label %Lend0
L3:
%t10=load i32, i32* %t0
%cond2 = icmp eq i32 %t10, 3
br i1 %cond2, label %L4, label %L5
L4:
%t11= call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([13 x i8], [13 x i8]* @str2, i64 0, i64 0))
br label %Lend0
L5:
%t12=load i32, i32* %t1
%t13= call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @str3, i64 0, i64 0), i32 %t12)
br label %Lend0
Lend0:
br label %Lend1
L1:
%t14= call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([7 x i8], [7 x i8]* @str4, i64 0, i64 0))
br label %Lend1
Lend1:

; === epilogue ===
ret i32 0
}
