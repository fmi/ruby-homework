describe "Asm.asm" do
  it "works with empty programs" do
    Asm.asm {}.should eq [0, 0, 0, 0]
  end

  it "implements MOV" do
    Asm.asm do
      mov ax, 3
      mov bx, 4
      mov cx, ax
    end.should eq [3, 4, 3, 0]
  end

  it "implements INC" do
    Asm.asm do
      inc ax
      inc bx, 3
      inc cx, bx
    end.should eq [1, 3, 3, 0]
  end

  it "implements DEC" do
    Asm.asm do
      mov ax, 3
      dec ax
      mov bx, 4
      dec bx, 2
      mov cx, 7
      dec cx, ax
    end.should eq [2, 2, 5, 0]
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

    Asm.asm do
      cmp ax, bx
      je 3
      mov cx, 10
      mov dx, 1
    end.should eq [0, 0, 0, 1]

    Asm.asm do
      cmp ax, bx
      jne 3
      mov cx, 1
      mov dx, 1
    end.should eq [0, 0, 1, 1]

    Asm.asm do
      mov bx, 4
      cmp ax, bx
      jl success
      mov cx, 1
      label success
      mov dx, 1
    end.should eq [0, 4, 0, 1]
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

  it "implements LABEL" do
    Asm.asm do
      mov ax, 1
      cmp ax, 1
      je l1
      inc cx
      label l1
      inc bx
    end.should eq [1, 1, 0, 0]
  end

  it "can be used to find GCD of two numbers" do
    Asm.asm do
      mov ax, 40
      mov bx, 32
      label cycle
      cmp ax, bx
      je finish
      jl asmaller
      dec ax, bx
      jmp cycle
      label asmaller
      dec bx, ax
      jmp cycle
      label finish
    end.should eq [8, 8, 0, 0]
  end
end
