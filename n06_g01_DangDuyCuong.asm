#==========================================
# Project 6 : Tao ham malloc 
# Dang Duy Cuong k63 20180033
# ý tưởng: 
#	+ Tạo 1 vùng không gian tự do tên là Sys_MyFreeSpace như là 1 stack để lưu trữ các giá trị được 
# cấp phát 
#       + 1 vùng nhớ tên là Sys_MyVariable lưu điạ chỉ của biến trong không gian Sys_MyFreeSpace
# 	+ Biến Sys_TheTopOfFree trỏ đến đầu không gian Sys_MyFreeSpace là vùng nhớ đầu tiên trống 
#	+ Biến Sys_CountVariable thể hiện số lượng biến hiện tại được cấp phát 
#	+ Khi truy cập biến thì cần phải nhớ thứ tự mà mình nhập biến (đó chính là tên biến) để lấy giá trị, 
# lấy địa chỉ, set giá trị,...
#==========================================



.data
menu: .asciiz "1.Khoi tao\n2.Tao bien\n3.Tao mang 2 chieu\n4.Lay gia tri\n5.Lay dia chi\n6.Lay gia tri mang 2 chieu\n7.Gan gia tri mang 2 chieu\n8.Copy 2 con tro xau ki tu\n9.So luong bo nho da cap phat\n10.Thoat"
thong_bao_loi: .asciiz "Nhap khong dung format"
thong_bao_khoi_tao: .asciiz "Ban phai khoi tao truoc"
thong_bao_loi_word: .asciiz "Word phai co kich thuoc 1 phan tu la 4 byte"
thong_bao_loi_char: .asciiz "Char phai co kich thuoc 1 phan tu la 1 byte"
thong_bao_thanh_cong: .asciiz "Gan gia tri thanh cong"
thong_bao_max_bo_nho:  .asciiz "Qua bo nho cho phep"
nhap_kieu_bien: .asciiz "Nhap kieu bien (1 = Char | 2 = Byte | 3 = Word)"
nhap_so_luong_bien: .asciiz "Nhap so luong bien (so nguyen duong)"
nhap_kich_thuoc_bien: .asciiz "Nhap kich thuoc 1 phan tu cua bien tinh theo byte (so nguyen duong | word phai la 4 byte)"
nhap_check: .asciiz "Tao thanh cong"
nhap_hang_mang: .asciiz "Nhap hang cua mang 2 chieu"
nhap_cot_mang: .asciiz "Nhap cot cua mang 2 chieu"
nhap_bien:  .asciiz "Truy cap bien thu may"
nhap_vi_tri: .asciiz "Nhap vi tri dia chi muon truy cap, coi dia chi bien la vi tri dau tien (index = 1)"
hien_thi_gia_tri: .asciiz "Gia tri cua bien la "
hien_thi_dia_chi: .asciiz "Dia chi cua bien la "
hien_thi_bo_nho: .asciiz "So luong bo nho da cap la "
nhap_hang_i:  .asciiz "Nhap vi tri hang i"
nhap_cot_j:  .asciiz "Nhap vi tri cot j"
nhap_gia_tri: .asciiz "Nhap gia tri muon gan cho bien"
nhap_bien_1: .asciiz "Nhap bien dau tien "
nhap_bien_2: .asciiz "Nhap bien thu hai "

.kdata
# Bien chua vi tri dau tien cua vung nho con trong
Sys_TheTopOfFree: .word  -1 

# Vung khong gian tu do, dung de cap bo nho cho cac bien con tro
Sys_MyFreeSpace: .space  4000
# Bộ nhớ max
Sys_MaxSpace: .word 4000
# Vùng không gian dùng để lưu địa chỉ được cấp phát của các biến con trỏ
Sys_MyVariable: .space 100

# Bien luu so luong bien
Sys_CountVariable: .word -1

.text
main:		jal dau_vao_menu  # hiện thị menu
		nop
		beq $a1, -2, exit_program	# nếu cancel thì thoát chương trình
		beq $a1, 0, if_1		# nhập đúng thì bắt đầu xét 
loi_nhap_menu:	li $v0, 55
  		la $a0, thong_bao_loi		# nhập không đúng thì báo lỗi 
		li $a1, 2
		syscall		
		j main				# nhập k đúng thì quay lại main
		
if_1:		bne $a0, 1, kiem_tra_khoi_tao	# nếu nhập = 1 -> khiểm tra xem khỏi 
		jal xuly_1			# hàm khỏi tạo 
		nop
		j main			

kiem_tra_khoi_tao:	la $t9, Sys_TheTopOfFree	# lấy địa chỉ biến lưu thông tin bộ nhớ đầu còn trống 
		   	lw $t1, 0($t9)			# lấy giá trị biến lưu thông tin bộ nhớ đầu còn trống 
		   	bne $t1, -1, if_2		# nếu khác -1 thì là đã tạo biến r 
		   	li $v0, 55			# chưa tạo biến thì phải tạo biến trước, in thông báo 
		   	la $a0, thong_bao_khoi_tao
			li $a1, 2
			syscall	
			j main
			
if_2:		bne $a0, 2, if_3
		jal ham_nhap_bien # nhập biến 
		nop
		bne $s5, $zero, if_2_1 # nếu lỗi thì quay lại main
		j main	
if_2_1:		move $a0, $s7    # parameter $a0 = return $s7 (kich thuoc 1 phan tu)
		move $a1, $s6	 # parameter $a1 = return $s6 (so luong phan tu)
		move $a2, $s5	 # parameter $a2 = return $s5 (loại kiểu)
		jal xuly_2
		nop 
		j main
if_3:		bne $a0, 3, if_4
		jal nhap_3_1	# nhập mảng 2 chiều 
		nop
		move $a0, $s2    # parameter $a0 = return $s7 (kich thuoc 1 phan tu)
		move $a1, $s1	 # parameter $a1 = return $s6 (so luong phan tu)
		move $a2, $s0	 # parameter $a2 = return $s5 (loại kiểu)
		jal xuly_2
		nop
		j main
if_4:		bne $a0, 4, if_5
		jal nhap_4_1	#nhập biến 
		nop
		move $a0, $s2    # parameter $a0 = return $s2 (kich thuoc 1 phan tu)
		move $a1, $s1	 # parameter $a1 = return $s1 (so luong phan tu)
		move $a2, $s0	 # parameter $a2 = return $s0 (loại kiểu)
		jal xuly_3
		nop
		j main
if_5:		bne $a0, 5, if_6
nhap_5_1:	li $v0, 51	# Nhập vị trí của biến trong bộ nhớ (tên biến )
		la $a0, nhap_bien
		syscall
		beq $a1, -2, main
		bne $a1, 0, nhap_5_1
		jal xuly_4	# hàm xử lý lấy giá trị
		nop
		j main
if_6:		bne $a0, 6, if_7
		jal nhap_6_1	# nhập mảng 2 chiều 
		nop
		move $a1, $s3  # parameter $a1 = kich thuoc
		move $a2, $s4  # parameter $a2 = vi tri can lay trong bo nho 
		move $a3, $s0  # parameter $a3 = loai kieu bien
		jal xuly_5
		nop		
		j main
if_7:		bne $a0, 7, if_8
		jal nhap_7_1
		nop
		move $a1, $s3  # parameter $a1 = kich thuoc
		move $a2, $s4  # parameter $a2 = vi tri can lay trong bo nho 
		move $a3, $s0  # parameter $a3 = loai kieu bien
		jal xuly_6
		nop				
		j main
if_8:		bne $a0, 8, if_9
		jal nhap_8_1		# nhập dữ liệu 
		nop
		move $s2, $a0
		move $a0, $s1    # parameter $a0 = Nhập vị trí của biến dau tien trong bộ nhớ
		move $a1, $s2	 # parameter $a1 = Nhập vị trí của biến thu hai trong bộ nhớ
		jal xuly_7
		nop		
		j main  
if_9:		bne $a0, 9, if_10	# chức năng in số lượng bộ nhớ đã dùng 
		jal xuly_8	
		nop
		j main
if_10:		bne $a0, 10, if_11
		j exit_program			# chức năng thoát chương trình 
if_11:		j loi_nhap_menu
		nop
exit_program:	li $v0, 10                      # end program
        	syscall	

#------------------------------------------
#  Ham nhap copy 2 xau ki tu
#  @param    khong co
#
#  @return   $a0   vị trí của biến thu hai trong bộ nhớ
#  @return   $s1   vị trí của biến dau tien trong bộ nhớ 
#------------------------------------------ 
nhap_8_1:	li $v0, 51	# Nhập vị trí của biến dau tien trong bộ nhớ (tên biến )
		la $a0, nhap_bien_1
		syscall
		beq $a1, -2, main
		bne $a1, 0, nhap_8_1
		move $s1, $a0
nhap_8_2:	li $v0, 51	# Nhập vị trí của biến thứ hai trong bộ nhớ (tên biến )
		la $a0, nhap_bien_2
		syscall
		beq $a1, -2, main
		bne $a1, 0, nhap_8_2
		jr $ra
		nop

#------------------------------------------
#  Ham nhap gan gia tri mang 2 chieu
#  @param    khong co
#
#  @return   $a0   vi tri cua bien trong bo nho
#  @return   $s0   lọai kiểu của biến
#  @return   $s4   vi trí cần lấy giá trị tính từ vị trí của con trỏ đầu 
#  @return   $s3   kích thước 1 phần tử   
#------------------------------------------ 
nhap_7_1:	li $v0, 51		# nhập kiểu biến 
  		la $a0, nhap_kieu_bien
		syscall
		beq $a1, -2, main
		bne $a1, 0, nhap_7_1
		move $s0, $a0  # luu $s0 = ten kieu
nhap_7_2:       li $v0, 51		# nhập hàng mảng 2 chiều 
  		la $a0, nhap_hang_mang
		syscall
		beq $a1, -2, main
		bne $a1, 0, nhap_7_2
		move $s1, $a0  # luu $s1 = so hang
nhap_7_3:	li $v0, 51		# nhập số cột 
  		la $a0, nhap_cot_mang
		syscall
		beq $a1, -2, main
		bne $a1, 0, nhap_7_3
		move $s2, $a0 # luu $s2 = so cot
nhap_7_4:       li $v0, 51		# nhập kích thước của mỗi biến 
  		la $a0, nhap_kich_thuoc_bien
		syscall
		beq $a1, -2, main
		bne $a1, 0, nhap_7_4
		move $s3, $a0 # luu $s3 = kich thuoc 1 phan tu cua bien
nhap_7_5:	li $v0, 51		# nhập hàng cầp truy cập 
  		la $a0, nhap_hang_i
		syscall
		beq $a1, -2, main
		bne $a1, 0, nhap_7_5		
		mul $s4, $s1, $a0  # $s4 = cot * i  
nhap_7_6:	li $v0, 51		# nhập cột cần truy cập 
  		la $a0, nhap_cot_j
		syscall
		beq $a1, -2, main
		bne $a1, 0, nhap_7_6		
		add $s4, $s4, $a0  # $s4 = cot * i + j truy cap den vi tri [i,j] cua mang 
nhap_7_7:	li $v0, 51
  		la $a0, nhap_gia_tri
		syscall
		beq $a1, -2, main
		bne $a1, 0, nhap_7_7		
		move $t0, $a0 	# parameter $t0 = giá trị gán cho biến  
nhap_7_8:	li $v0, 51	# Nhập vị trí của biến trong bộ nhớ (tên biến )
		la $a0, nhap_bien
		syscall
		beq $a1, -2, main
		bne $a1, 0, nhap_7_8
		jr $ra
		nop


#------------------------------------------
#  Ham nhap lay gia tri mang 2 chieu
#  @param    khong co
#
#  @return   $a0   vi tri cua bien trong bo nho
#  @return   $s0   lọai kiểu của biến
#  @return   $s4   vị trí biến  
#  @return   $s3   kích thước 1 phần tử   
#------------------------------------------ 
nhap_6_1:	li $v0, 51		# nhap kieu bien
  		la $a0, nhap_kieu_bien
		syscall
		beq $a1, -2, main
		bne $a1, 0, nhap_6_1
		move $s0, $a0  # luu $s0 = ten kieu
nhap_6_2:       li $v0, 51		# nhap so hang
  		la $a0, nhap_hang_mang
		syscall
		beq $a1, -2, main
		bne $a1, 0, nhap_6_2
		move $s1, $a0  # luu $s1 = so hang
nhap_6_3:	li $v0, 51		# nhập số cột 
  		la $a0, nhap_cot_mang
		syscall
		beq $a1, -2, main
		bne $a1, 0, nhap_6_3
		move $s2, $a0 # luu $s2 = so cot
nhap_6_4:       li $v0, 51		# nhap kich thuoc bien 
  		la $a0, nhap_kich_thuoc_bien
		syscall
		beq $a1, -2, main
		bne $a1, 0, nhap_6_4
		move $s3, $a0 # luu $s3 = kich thuoc 1 phan tu cua bien
nhap_6_5:	li $v0, 51		# nhap hang i
  		la $a0, nhap_hang_i
		syscall
		beq $a1, -2, main
		bne $a1, 0, nhap_6_5		
		mul $s4, $s1, $a0  # $s4 = cot * i  
nhap_6_6:	li $v0, 51  		# nhap cot j
  		la $a0, nhap_cot_j  
		syscall
		beq $a1, -2, main
		bne $a1, 0, nhap_6_6		
		add $s4, $s4, $a0  # $s4 = cot * i + j truy cap den vi tri [i,j] cua mang 		
nhap_6_7:	li $v0, 51	# Nhập vị trí của biến trong bộ nhớ (tên biến )
		la $a0, nhap_bien
		syscall
		beq $a1, -2, main
		bne $a1, 0, nhap_6_7
		jr $ra
		nop
#------------------------------------------
#  Ham nhap lay gia tri
#  @param    khong co
#  
#  @return   $s0   lọai kiểu của biến, nếu = 0 thì lỗi 
#  @return   $s2   vị trí biến  
#  @return   $s1   kích thước 1 phần tử   
#------------------------------------------  
nhap_4_1:	li $v0, 51			# nhap kieu bien
  		la $a0, nhap_kieu_bien
		syscall
		beq $a1, -2, main
		bne $a1, 0, nhap_4_1
		move $s0, $a0  # luu $s0 = ten kieu
nhap_4_2:       li $v0, 51			# nhap kich thuoc bien
  		la $a0, nhap_kich_thuoc_bien
		syscall
		beq $a1, -2, main
		bne $a1, 0, nhap_4_2
		move $s1, $a0  # $s1 = kích thước 1 phần tử 
nhap_4_3:	li $v0, 51           # nhap vi tri bien
		la $a0, nhap_bien
		syscall
		beq $a1, -2, main
		bne $a1, 0, nhap_4_3
		move $s2, $a0   # $s2 = vi tri bien
        	jr $ra
        	nop
        	
        	       	       	
#------------------------------------------
#  Ham nhap bien 
#  @param    khong co
#  
#  @return   $s5   lọai kiểu của biến, nếu = 0 thì lỗi 
#  @return   $s6   số lượng biến 
#  @return   $s7   kích thước 1 phần tử   
#------------------------------------------   
ham_nhap_bien:	li $v0, 51			# nhập kiểu 
  		la $a0, nhap_kieu_bien
		syscall
		beq $a1, -2, main
		bne $a1, 0, ham_nhap_bien
		move $s5, $a0  			# luu $s5 = ten kieu
nhap_bien1:	li $v0, 51			# nhập số lượng biến 
  		la $a0, nhap_so_luong_bien
		syscall
		beq $a1, -2, main
		bne $a1, 0, nhap_bien1
		move $s6, $a0 			# luu $s6 = số lượng biến 
nhap_bien2:	li $v0, 51     			# Nhập kích thước 1 phần tử 
  		la $a0, nhap_kich_thuoc_bien
		syscall
		beq $a1, -2, main
		bne $a1, 0, nhap_bien2
		move $s7, $a0  			# $s7 = kích thước 1 phần tử 
		bne $s5, 3, check_bien
		beq $s7, 4, out_nhap_bien
		nop
		li $s5, 0			# tra ve loi 
		li $v0, 55			# thong bao nhap loi word
		la $a0, thong_bao_loi_word
		li $a1, 2
		syscall	
		j out_nhap_bien
		nop
		
check_bien:	bne $s5, 1, out_nhap_bien
		beq $s7, 1, out_nhap_bien
		li $s5, 0			# tra ve loi 
		li $v0, 55			# thong bao nhap loi char
		la $a0, thong_bao_loi_char
		li $a1, 2
		syscall	
		jr $ra
		nop
		
out_nhap_bien:	jr $ra
		nop

#------------------------------------------
#  Ham nhap menu 
#  @param    khong co
#  @detail   in menu và nhập chọn chức năng
#------------------------------------------   	
dau_vao_menu:	li $v0, 51
		la $a0, menu 
		syscall
		jr $ra
		nop	
		         	
#------------------------------------------
#  Ham nhap mang 2 chieu
#  @param    khong co
#
#  @return   $s0  loại kiểu 
#  @return   $s1  số lượng phần tử 
#  @return   $s2  kích thước phần tử 
#------------------------------------------          	        
nhap_3_1:	li $v0, 51                 # nhap kiểu 
  		la $a0, nhap_kieu_bien
		syscall
		beq $a1, -2, main
		bne $a1, 0, nhap_3_1
		move $s0, $a0  # luu $s0 = ten kieu
nhap_3_2:       li $v0, 51 		# nhập số hàng 
  		la $a0, nhap_hang_mang
		syscall
		beq $a1, -2, main
		bne $a1, 0, nhap_3_2
		move $s1, $a0  # luu $s1 = so hang
nhap_3_3:	li $v0, 51		# nhập số cột 
  		la $a0, nhap_cot_mang
		syscall
		beq $a1, -2, main
		bne $a1, 0, nhap_3_3
		mul $s1, $s1, $a0  # luu $s1 = so hang * so cot (tuong ung voi so luong phan tu)
nhap_3_4:       li $v0, 51          # nhập kích thước biến 
  		la $a0, nhap_kich_thuoc_bien 
		syscall
		beq $a1, -2, main
		bne $a1, 0, nhap_3_4
		move $s2, $a0      # luu $s2 = kích thước biến       	        	
		jr $ra 
		nop
		
		
#------------------------------------------
#  Ham khoi tao cho viec cap phat dong
#  @param    khong co
#  @detail   Danh dau vi tri bat dau cua vung nho co the cap phat duoc
#------------------------------------------
xuly_1: 	la   $t9, Sys_TheTopOfFree  	#lấy địa chỉ index đầu tiên còn trống của vùng nhớ
		la   $t7, Sys_CountVariable	#lấy địa chỉ biến lưu số lượng biến
		li   $t1, 0
		sw   $t1, 0($t9)		# khởi tạo Sys_TheTopOfFree = 0
		li   $t2, 0
		sw   $t2, 0($t7) 		# khởi tạo Sys_CountVariable = 0
		jr   $ra
		nop
		
		
#------------------------------------------
#  Ham cap phat bo nho dong cho cac bien con tro
#  @param  	  $a0   Kich thuoc 1 phan tu, tinh theo byte
#  @param         $a1   So phan tu can cap phat
#  @param         $a2   Loai cap phap cua bien, co 3 loai (Char, Byte, Word) tuong ung la (1, 2, 3)
#
#  @detail   địa chỉ được cấp phát được lưu vào Sys_MyVariable[Sys_CountVariable], Sys_CountVariable là id của biến 
#	     bộ nhớ được cấp pháp lưu vào Sys_MyFreeSpace với ô nhớ bắt đầu từ Sys_MyVariable[Sys_CountVariable]	    	
#------------------------------------------
xuly_2:   	bne  $a2, 3, cap_phat  	# Neu $a2 != 3 thi cap phat binh thuong
		beq  $a0, 4, cap_phat  	# Neu $a2 == 3 (la Word/ mang Word) thi kiem tra xem 
		   			# kich thuoc 1 phan tu co bang 4 khong ($a0 == 4)
		li $v0, 55
		la $a0, thong_bao_loi_word
		li $a1, 2
		syscall	
		jr   $ra
		nop
cap_phat:	la   $t9, Sys_TheTopOfFree   	# load địa chỉ vị trí của vùng nhớ trống 
		la   $t8, Sys_MyFreeSpace 	# load địa chỉ vùng nhớ trống 
		la   $t7, Sys_MyVariable        # load địa chỉ vùng nhớ lưu địa chỉ biến 
		la   $t6, Sys_CountVariable	# load địa chỉ vị trí của biến trong vùng nhớ lưu địa chỉ biến  
		lw   $t5, 0($t6)		# $t5 =  Sys_CountVariable
		mul  $t1, $t5, 4		# $t1 =  $t5 * 4    mỗi phần tử tương ứng với 4 byte 
		add  $t7, $t7, $t1		# truy cập địa chỉ của Sys_MyVariable[Sys_CountVariable]
		
		lw   $t4, 0($t9)		# $t4 =  Sys_TheTopOfFree
		
		# truy cập địa chỉ của ô nhớ đầu tiên còn trống Sys_MyFreeSpace[Sys_TheTopOfFree]
		add  $t8, $t8, $t4   		
						 
		# Sys_MyVariable[Sys_CountVariable] = địa chỉ của Sys_MyFreeSpace[Sys_TheTopOfFree] 
		# (lưu lại vị trí ô nhớ đầu tiên của biến) 
		sw   $t8, 0($t7)		 
		
		mul  $t1, $a1, $a0   		# $t1 = số phần tử * kính thước ptu (Tinh kich thuoc ô nhớ cần cấp phát)
		add  $t4, $t4, $t1  		# $t4 = $t4 + $t1 (Tinh dia chi dau tien con trong) 
		
		la   $s1, Sys_MaxSpace          # lấy địa chỉ của biến maxspace
		lw   $s2, 0($s1)		# lấy giá trị của maxspace
		slt  $s3, $s2, $t4              # Nếu Sys_MaxSpace < Sys_TheTopOfFree thí $s3 = 1
		bnez $s3, bao_loi_max 		# nếu Sys_MaxSpace < Sys_TheTopOfFree thì báo lỗi 
		
		sw   $t4, 0($t9)		# Sys_TheTopOfFree = $t4 (cập nhập chỉ số vị trí phần tử còn trống) 
		
		
		add  $t5, $t5, 1 		# $t5 = $t5 + 1 (Tăng số lượng biến lên 1)
		sw   $t5, 0($t6)		# Sys_CountVariable = $t5 (cập nhập số lượng biến)
		
		li $v0, 55			# in thông báo tạo biến thành công 
		la $a0, nhap_check
		li $a1, 1
		syscall	
		jr   $ra
		nop
		
bao_loi_max:    sub $t4, $t4, $t1
		sw  $t4, 0($t9)		# Sys_TheTopOfFree = $t4 (cập nhập chỉ số vị trí phần tử còn trống) 
		li $v0, 55			# in thông báo lỗi nhập max mảng 
		la $a0, thong_bao_max_bo_nho
		li $a1, 1
		syscall	
		jr $ra
		nop		
#------------------------------------------
#  Ham lay gia tri Word/Byte cua cac bien con tro (tương tự *contro)
#  @param  [in]       $a0   Chua vị trí cua bien con tro (tên biến)
#  @param  [in]       $a1   Kich thuoc 1 phan tu, tinh theo byte
#  @param  [in]       $a2   Loai cap phap cua bien, co 3 loai (Char, Byte, Word) tuong ung la (1, 2, 3)	
#
#  @detail  Từ vị trí biến con trỏ truy cập Sys_MyVariable[$a0] lấy được địa chỉ của biến trong Sys_MyFreeSpace 
#	    rồi in ra biến ở phần tử $a0 trong bộ nhớ Sys_MyFreeSpace
#------------------------------------------
xuly_3:		la   $t9, Sys_MyVariable 	# load địa chỉ vùng nhớ lưu địa chỉ biến
		add  $a0, $a0, -1		# index được đánh số từ 0 nên -1 để về đúng index 
		mul  $a0, $a0, 4		# mỗi phần tử là 4 byte 
		add  $t9, $t9, $a0      	# địa chỉ phần tử Sys_MyVariable[$a0]
		lw   $s1, 0($t9)		# truy cập phần tử Sys_MyVariable[$a0]
		lw   $s2, 0($s1)		# $s2 = giá trị cua con tro trong bộ nhớ Sys_MyFreeSpace
		
		#bne  $a3, 3, in_char		# if a3 != 3 thi la kieu char
		li   $v0, 56			# in kieu word 
		la   $a0, hien_thi_gia_tri 
		move $a1, $s2
		syscall 
		jr $ra
		nop
		
#------------------------------------------
#  Ham lay dia chi Word/Byte cua cac bien con tro (tương tự &contro)
#  @param  [in]       $a0   Chua vị trí cua bien con tro (tên biến)
#  @detail  Từ vị trí biến con trỏ truy cập Sys_MyVariable[$a0] lấy được địa chỉ của biến trong Sys_MyFreeSpace 
#------------------------------------------
xuly_4:		la   $t9, Sys_MyVariable 	# load địa chỉ vùng nhớ lưu địa chỉ biến
		add  $a0, $a0, -1		# index được đánh số từ 0 nên -1 để về đúng index 
		mul  $a0, $a0, 4		# mỗi phần tử là 4 byte 
		add  $t9, $t9, $a0      	# địa chỉ phần tử Sys_MyVariable[$a0]
		lw   $s1, 0($t9)		# truy cập phần tử Sys_MyVariable[$a0]
	
		li   $v0, 56			# in địa chỉ 
		la   $a0, hien_thi_dia_chi
		move $a1, $s1
		syscall 
		jr $ra
		nop

#------------------------------------------
#  Ham lay gia tri Word/Byte cua cac bien con tro là mảng 2 chiều 
#  @param  [in]       $a0   Chua vị trí cua bien con tro (tên biến)
#  @param  [in]       $a1   Kich thuoc 1 phan tu, tinh theo byte
#  @param  [in]	      $a2   vi trí cần lấy giá trị tính từ vị trí của con trỏ đầu 
#  @param  [in]       $a3   Loai cap phap cua bien, co 3 loai (Char, Byte, Word) tuong ung la (1, 2, 3)	
#
#  @detail  Từ vị trí biến con trỏ truy cập Sys_MyVariable[$a0] lấy được địa chỉ của biến trong Sys_MyFreeSpace 
#	    rồi in ra biến ở phần tử $a2 * $a1 (Kich thuoc 1 phan tu) trong bộ nhớ Sys_MyFreeSpace
#------------------------------------------
xuly_5: 	la   $t9, Sys_MyVariable 	# load địa chỉ vùng nhớ lưu địa chỉ biến
		add  $a0, $a0, -1		# index được đánh số từ 0 nên -1 để về đúng index 
		mul  $a0, $a0, 4		# mỗi phần tử là 4 byte 
		add  $t9, $t9, $a0      	# địa chỉ phần tử Sys_MyVariable[$a0]
		lw   $s1, 0($t9)		# truy cập phần tử Sys_MyVariable[$a0]
		
		add  $a2, $a2, -1 		# index được đánh số từ 0 nên -1 để về đúng index 
		mul  $a2, $a2, $a1		# định vị vị trí của con trỏ trong bộ nhớ 
		add  $s1, $s1, $a2		# địa chỉ phần tử vị trí $a1 * $a2 trong Sys_MyFreeSpace
		
		lw   $s2, 0($s1)
		#bne  $a3, 3, in_char		# if a3 != 3 thi la kieu char
		li   $v0, 56			# in kieu word 
		la   $a0, hien_thi_gia_tri 
		move $a1, $s2
		syscall 
		jr $ra
		nop
		
		
#------------------------------------------
#  Ham gán gia tri Word/Byte cua cac bien con tro là mảng 2 chiều 
#  @param  [in]       $a0   Chua vị trí cua bien con tro (tên biến)
#  @param  [in]       $a1   Kich thuoc 1 phan tu, tinh theo byte
#  @param  [in]	      $a2   vi trí cần lấy giá trị tính từ vị trí của con trỏ đầu 
#  @param  [in]       $a3   Loai cap phap cua bien, co 3 loai (Char, Byte, Word) tuong ung la (1, 2, 3)	
#  @param  [in]       $t0   Giá trị dùng để gán 
#  @detail  Từ vị trí biến con trỏ truy cập Sys_MyVariable[$a0] lấy được địa chỉ của biến trong Sys_MyFreeSpace 
#	    rồi truy cập biến ở phần tử $a2 * $a1 (Kich thuoc 1 phan tu) trong bộ nhớ Sys_MyFreeSpace
#           rồi gán nó bằng giá trị $t0
#------------------------------------------
xuly_6: 	la   $t9, Sys_MyVariable 	# load địa chỉ vùng nhớ lưu địa chỉ biến
		add  $a0, $a0, -1		# index được đánh số từ 0 nên -1 để về đúng index 
		mul  $a0, $a0, 4		# mỗi phần tử là 4 byte 
		add  $t9, $t9, $a0      	# địa chỉ phần tử Sys_MyVariable[$a0]
		lw   $s1, 0($t9)		# truy cập phần tử Sys_MyVariable[$a0]
		
		add  $a2, $a2, -1 		# index được đánh số từ 0 nên -1 để về đúng index 
		mul  $a2, $a2, $a1		# định vị vị trí của con trỏ trong bộ nhớ 
		add  $s1, $s1, $a2		# $s1 lưu địa chỉ phần tử vị trí $a1 * $a2 trong Sys_MyFreeSpace
		
		sw   $t0, 0($s1)		# gán $t0 vào địa chỉ s1 (là vị trí [i][j] trong mảng)
		li $v0, 55			# in thông báo gán biến thành công 
		la $a0, thong_bao_thanh_cong
		li $a1, 1
		syscall	
		jr   $ra
		nop

#------------------------------------------
#  Copy bien con trỏ thứ 2 = con trỏ thứ nhất 
#  @param  [in]       $a0   Chua vị trí cua bien con tro thu nhat (tên biến)
#  @param  [in]       $a1   Chua vị trí cua bien con tro thu hai (tên biến)
#
#  @detail  Từ vị trí biến con trỏ truy cập Sys_MyVariable[$a0] và  Sys_MyVariable[$a1] lấy được 
#           địa chỉ của 2 biến trong Sys_MyFreeSpace. Gán giá trị địa chỉ của biến $a0 = $a1
#------------------------------------------
xuly_7:		la   $t9, Sys_MyVariable 	# load địa chỉ vùng nhớ lưu địa chỉ biến
		add  $a0, $a0, -1		# index được đánh số từ 0 nên -1 để về đúng index 
		mul  $a0, $a0, 4		# mỗi phần tử là 4 byte 
		add  $t9, $t9, $a0      	# địa chỉ phần tử Sys_MyVariable[$a0]
		
		la   $t8, Sys_MyVariable 	# load địa chỉ vùng nhớ lưu địa chỉ biến
		add  $a1, $a1, -1		# index được đánh số từ 0 nên -1 để về đúng index 
		mul  $a1, $a1, 4		# mỗi phần tử là 4 byte 
		add  $t8, $t8, $a1      	# địa chỉ phần tử Sys_MyVariable[$a1]
		lw   $s1, 0($t8)		# truy cập phần tử Sys_MyVariable[$a1]
		
		sw   $s1, 0($t9)                # Gán giá trị địa chỉ của biến $a0 = giá trị của biến $a1
		
		li $v0, 55			# in thông báo gán biến thành công 
		la $a0, thong_bao_thanh_cong
		li $a1, 1
		syscall	
		jr   $ra
		nop
		
		
#------------------------------------------
#  số lượng bộ nhớ đã cấp phát 
#  @param  không có 
#  @detail  Truy cập giá trị Sys_TheTopOfFree là số lượng bộ nhớ đã cấp phát 
#------------------------------------------		
xuly_8:		la $t9, Sys_TheTopOfFree
		lw $s1, 0($t9)
		li   $v0, 56			# hiển thị bộ nhớ đã cấp phát 
		la   $a0, hien_thi_bo_nho 
		move $a1, $s1
		syscall 
		jr $ra
		nop 
