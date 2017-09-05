defmodule GitWerkGuts.SshKeyTest do
  use ExUnit.Case
  alias GitWerkGuts.SshKey

  @valid_rsa_key "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDV7zn4vREzmECWKK8EHaR/uPzMO10KIBHN3fRG0z4l3RjF+ivBwfiFmBdf52gaNfc8Wfs86jRa6MY0MJxWVq9pRyha0sVnUAzVyNBSm5tSeQyYEufTOSk2OGil/flW8F6b0EGsnIMNc37TQNdUHsVNxEw+It3Qym6utrF8AXKTBdWtPia95ynYGER1XAFhZ/nH0dXgqFEaIHDtpKV4FxrvzqST7fwU4O2z7AjOeuvrIkOioFrbS9O8Wa+MekPGE/9neYpbKTNUqTaYSx/Fo4psLvcGLnWcNLk9Gj/6P8SRYThmEtM5YEaN1/yESnIeuCR+XxV0UpCZMkausIe/d2Lv"
  @valid_dsa_key "ssh-dss AAAAB3NzaC1kc3MAAACBAIIXM6KuF78arZ+sKDQxNyhyFmS7vB8sguMGwrLinktDj1EgoiVEiqudR7mwTeYPKdzfPY1EZQeNDJ+DzLUy01c+LOXmGN45fb5RcKjmCsnkRUbEZJDXIn0utohqNZn414Pr0Tb+Yivb/80LVF87qpbEv276H5Sf87jKGe98nthdAAAAFQDd8tu0WwyBnfOJGOIF1VlJwXSDwQAAAIAfVgH3aFPsHqVqopjDvzT5yUBcKp61f4IqJQtMKHcndSheuMq3AJs6Xo6GIAo4ZvsRu92B88FNsvfGsAxESqs6SYJQCv2d+znLlltNp1NYrv/HLk4J28pVRM6CDKOvlnT6CAA7zQFkacqFchnzQzqDQ/a4YU8kdDswWnDOiO4WjAAAAIALoTcDtdV5cyCAf05uDjjZfJonX74s4IjN2Cn9TlAUZmO5mEeALx91lbAbZ5avOYZXpaLk9veIaF9/9sQBZOm2r0EUtoVxWyzOYj7tF6fzWuxt7zxY5vjQH7G7+gEy+h4z++jRxDY6eH+iA3/yVUIF7uJ+1GAtmqQxTBvbmNek9A=="
  @valid_ed25519_key "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIi2vk3tcYqQHOecJDULiWwFPYR0tmVRlp9iJGBFdyaq"
  @valid_ecdsa_521_key "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAHyAd3Zn31xbpUCm4JaSqPD9NJ+oDeBCNWgJegV/urHk7Wj/ntdp9B92jrdsJqKv3n3w70MotKIs8FOlfUoIkIpKQFUd3cG94GWFTxMofPGUj4mRvNYSXw2RCSdtX0wkG49pzcpG+q2f0hWOHmlTydVvHq47LSvIKOzVX1p9Bb1Fxkcww=="
  @valid_ecdsa_256_key "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBLsHHDwJQbNLn5QVupl5wpxiDqcXw1QDUgvEMEL+fMCh8KfxA3mK0FL4Q2CcbjXTvkuuVbKRGWeii+dmy9qbEwM="
  @valid_ecdsa_384_key "ecdsa-sha2-nistp384 AAAAE2VjZHNhLXNoYTItbmlzdHAzODQAAAAIbmlzdHAzODQAAABhBHZ1hmUjimJ+tW8J57eS4d6K2fCD0BfU9peKjAId94gOvrOEyaXyYIvxUrfhdbD/pPFI5qSLXzcXA+rVRaPId9gL6P1sCelCdp9dNh0UdddlqiWxd1PvO4/3D61YIJNTYQ=="

  test "validate rsa key" do
    assert :ok == SshKey.validate_pub_key(@valid_rsa_key)
  end

  test "validate dsa key" do
    assert :ok == SshKey.validate_pub_key(@valid_dsa_key)
  end

  test "validate ed25519 key" do
    assert :ok == SshKey.validate_pub_key(@valid_ed25519_key)
  end

  test "validate valid_ecdsa_*_key" do
    assert :ok == SshKey.validate_pub_key(@valid_ecdsa_521_key)
    assert :ok == SshKey.validate_pub_key(@valid_ecdsa_256_key)
    assert :ok == SshKey.validate_pub_key(@valid_ecdsa_384_key)
  end

  test "validate wrong key" do
    assert {:error, _} = SshKey.validate_pub_key("ssh-rsa xaXaxaxaaxsaasdkjasjkadskjasdkj")
    assert {:error, :unknown_key} = SshKey.validate_pub_key("what ever")
  end
end
