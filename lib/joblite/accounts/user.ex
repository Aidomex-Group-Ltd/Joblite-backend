defmodule Joblite.Accounts.User do
  @moduledoc """
  A registered account. Email is the unique identity, normalized to lowercase.
  The password is stored only as a bcrypt hash; the plaintext never leaves a
  changeset validation boundary.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @type t :: %__MODULE__{}

  @email_regex ~r/^[^\s]+@[^\s]+\.[^\s]+$/

  schema "users" do
    field(:email, :string)
    field(:password, :string, virtual: true, redact: true)
    field(:hashed_password, :string, redact: true)
    field(:confirmed_at, :utc_datetime)

    timestamps(type: :utc_datetime)
  end

  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_email()
    |> validate_password()
    |> put_hashed_password()
    |> unique_constraint(:email)
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, @email_regex)
    |> validate_length(:email, max: 160)
    |> update_change(:email, &String.downcase/1)
  end

  defp validate_password(changeset) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 8, max: 72)
  end

  defp put_hashed_password(
         %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
       ) do
    put_change(changeset, :hashed_password, Bcrypt.hash_pwd_salt(password))
  end

  defp put_hashed_password(changeset), do: changeset
end
