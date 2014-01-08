describe "asm" do
  it "implements MOV" do
    Asm.asm do
      mov ax, 3
      mov cx, ax
    end.should eq [3, 0, 3, 0]
  end

  it "implements INC" do
    Asm.asm do
      inc ax
      inc bx, 3
      inc cx, bx
    end.should eq [1, 3, 3, 0]
  end

  it "implements CMP" do
    Asm.asm do
      mov ax, 2
      mov bx, 2
      cmp ax, bx
      je 5
      mov cx, 3
      mov dx, 3
    end.should eq [2, 2, 0, 3]
  end

  it "implements JMP" do
    Asm.asm do
      mov cx, 1
      jmp l1
      mov ax, 1
      label l1
      mov dx, 1
    end.should eq [0, 0, 1, 1]
  end
end
